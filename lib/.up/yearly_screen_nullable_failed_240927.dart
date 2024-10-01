import 'package:flutter/material.dart';
import 'package:prayer_times/models/api_pars.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/utils/date_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class YearlyScreen extends StatefulWidget {
  const YearlyScreen({super.key, required this.apiPars});
  final ApiPars apiPars;
  @override
  State<YearlyScreen> createState() => _YearlyScreenState();
}

class _YearlyScreenState extends State<YearlyScreen> {
  late Future<PrayerYear> _future;
  // DateTime date = DateTime.now(); // _focusedDay took place. In Daily, it was the selected date, passed to API
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, List<Datum>>? prayerYear;
  Map<DateTime, List<Prayer>> prayerPerDay = {};
  late final ValueNotifier<List<Prayer>> _selectedPrayers;

  void assignPrayerYear() {
    _future =
        ApiService.getPrayerYear(date: _focusedDay, apiPars: widget.apiPars);
  }

  Map<DateTime, List<Prayer>> mapPrayerYear(Map<String, List<Datum>> praYear) {
    for (var monthStr in praYear.keys) {
      for (var dayData in praYear[monthStr]!) {
        final int month = int.parse(monthStr);
        final int day = int.parse(dayData.date.gregorian.day);
        final date = DateTime(_selectedDay.year, month, day);
        prayerPerDay[date] = dayData.prayers.prayerList;
      }
    }
    return prayerPerDay;
  }

  @override
  void didUpdateWidget(covariant YearlyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.apiPars.city != oldWidget.apiPars.city ||
        widget.apiPars.country != oldWidget.apiPars.country ||
        widget.apiPars.method != oldWidget.apiPars.method) assignPrayerYear();
  }

  @override
  void dispose() {
    super.dispose();
    _selectedPrayers.dispose();
  }

  @override
  void initState() {
    super.initState();
    assignPrayerYear();
    prayerPerDay = mapPrayerYear(prayerYear!);
    _selectedDay = _focusedDay;
    _selectedPrayers = ValueNotifier(prayerPerDay[_selectedDay]!);
  }

  @override
  Widget build(BuildContext context) {
    // List<String> prayers = ['fajr', 'zuhr', 'asr', 'maghrib', 'isha'];
    // Map<DateTime, List<Prayer>> prayerPerDay = {};
    // for (var i = 0; i < 3; i++) {
    //   for (var i = 0; i < 3; i++) {
    //     prayerPerDay[DateUtils.dateOnly(DateTime(
    //       DateTime.now().year,
    //       DateTime.now().month,
    //       DateTime.now().day + i,
    //     ))] = prayers
    //         .map((prayerName) => Prayer(name: prayerName, time: '$i'))
    //         .toList();
    //   }
    // }
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Error
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data received.')); // No data
        } else if (snapshot.hasData) {
          prayerYear = snapshot.data!.yearData;
          return Column(
            children: [
              TableCalendar(
                // eventLoader: (day) => [Text('$day'), day.hour.toString()],
                // AFAIK, eventLoader shows n markers per each day, according to a given Map<DateTime, List<dynamic>>
                // Using a [LinkedHashMap] is highly recommended if you decide to use a map.
                calendarBuilders: CalendarBuilders(
                  headerTitleBuilder: (context, day) {
                    return ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: day, // Initiate at focused date (== day)
                          firstDate: DateTime(DateTime.now().year), // Start
                          lastDate: DateTime(DateTime.now().year + 62), // End
                        );
                        if (picked != null) {
                          setState(() {
                            bool isSameYear = _focusedDay.year == picked.year;
                            _focusedDay = _selectedDay = picked;
                            !isSameYear ? assignPrayerYear() : null;
                            _selectedPrayers.value = prayerPerDay[
                                    DateUtils.dateOnly(_selectedDay)] ??
                                [];
                          });
                        }
                      },
                      child: Text(
                        '${DateHelper.monthsAr[day.month - 1]} ${day.year}',
                      ),
                    );
                  },
                ),
                onHeaderTapped: (focusedDay) async {},
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'شهري',
                  CalendarFormat.twoWeeks: 'نصف شهري',
                  CalendarFormat.week: 'أسبوعي',
                },
                startingDayOfWeek: StartingDayOfWeek.saturday,
                weekendDays: const [DateTime.friday],
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 14),
                  weekendStyle: TextStyle(fontSize: 14),
                ),
                daysOfWeekHeight: MediaQuery.sizeOf(context).height / 35,
                locale: 'ar',
                firstDay: DateTime(DateTime.now().year),
                lastDay: DateTime(DateTime.now().year + 62),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _selectedPrayers.value =
                        prayerPerDay[DateUtils.dateOnly(selectedDay)] ?? [];
                  }
                },
                onPageChanged: (focusedDay) {
                  bool isSameYear = _focusedDay.year == focusedDay.year;
                  _focusedDay = focusedDay;
                  // setState(() {
                  // Cancel this setState if day loads its data on tap
                  !isSameYear ? assignPrayerYear() : null;
                  // });
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (cF) => setState(() => _calendarFormat = cF),
              ),
              Flexible(
                child: ValueListenableBuilder(
                  valueListenable: _selectedPrayers,
                  builder: (context, value, child) => ListView.builder(
                    shrinkWrap: true,
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Text(value[index].name),
                        trailing: Text(value[index].time),
                      );
                    },
                  ),
                ),
              )
            ],
          );
        } else {
          return const Center(child: Text('Unexpected error.')); // Fallback
        }
      },
    );
  }
}
