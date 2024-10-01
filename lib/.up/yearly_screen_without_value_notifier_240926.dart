import 'package:flutter/material.dart';
import 'package:prayer_times/models/api_pars.dart';
import 'package:prayer_times/models/prayer_day.dart';
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
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late final ValueNotifier<List<Prayer>> selectedPrayers;
  late List<Prayer> selectedList;

  void assignPrayerYear() {
    _future = ApiService.getPrayerYear(
      date: _focusedDay,
      apiPars: widget.apiPars,
    );
    // debugPrint('assignPrayer _focusedDay: $_focusedDay');
  }

  @override
  void didUpdateWidget(covariant YearlyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.apiPars.city != oldWidget.apiPars.city ||
        widget.apiPars.country != oldWidget.apiPars.country ||
        widget.apiPars.method != oldWidget.apiPars.method) assignPrayerYear();
  }

  @override
  void initState() {
    super.initState();
    assignPrayerYear();
    _selectedDay = _focusedDay;
    selectedPrayers = ValueNotifier([
      Prayer(name: 'test1', time: '7'),
      Prayer(name: 'test2', time: '2'),
      Prayer(name: 'test3', time: '7'),
    ]);
    selectedList = [
      Prayer(name: 'test1', time: '7'),
      Prayer(name: 'test2', time: '2'),
      Prayer(name: 'test3', time: '7'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<String> prayers = ['fajr', 'zuhr', 'asr', 'maghrib', 'isha'];
    Map<DateTime, List<Prayer>> prayerPerDay = {};
    for (var i = 0; i < 3; i++) {
      for (var i = 0; i < 3; i++) {
        prayerPerDay[DateUtils.dateOnly(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + i,
        ))] = prayers
            .map((prayerName) => Prayer(name: prayerName, time: '$i'))
            .toList();
      }
    }
    debugPrint(prayerPerDay.toString());
    // debugPrint('length: ${selectedPrayers.length}');

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
          // final prayerYear = snapshot.data!.dataYear /* .values.toList() */;
          return Column(
            children: [
              // ValueListenableBuilder(
              //   valueListenable: ValueNotifier(true),
              //   builder: (context, value, _) => Text(''),
              // ),
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
                  // formatButtonVisible: false,
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
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  selectedList =
                      prayerPerDay[DateUtils.dateOnly(selectedDay)] ?? [];
                  debugPrint('selectedDay: $_selectedDay');
                  debugPrint('ListDay: ${prayerPerDay.keys.toList()[1]}');
                  debugPrint('length: ${selectedPrayers.value.length}');
                  debugPrint('prayer name: ${selectedPrayers.value[1].name}');
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
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(selectedList[index].name),
                      trailing: Text(selectedList[index].time),
                    );
                  },
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
