import 'package:flutter/material.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/utils/date_helper.dart';
import 'package:prayer_times/widgets/prayer_list_view.dart';
import 'package:table_calendar/table_calendar.dart';

class YearlyScreen extends StatefulWidget {
  const YearlyScreen({super.key, required this.settings});
  final UserSettings settings;

  @override
  State<YearlyScreen> createState() => _YearlyScreenState();
}

class _YearlyScreenState extends State<YearlyScreen> {
  late Future<PrayerYear> _future;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, List<Datum>>? prayerYear;
  Map<DateTime, List<Prayer>> prayerPerDay = {};
  late final ValueNotifier<List<Prayer>> _selectedPrayers;

  Future<Map<DateTime, List<Prayer>>> assignPrayerYear() async {
    // API call + Map prayers per day (Create a yearly prayer map) + Assign prayer list as per selected day
    _future =
        ApiService.getPrayerYear(date: _focusedDay, apiPars: widget.settings);
    final PrayerYear prayerYear = await _future;
    final prayerYearData = prayerYear.yearData;
    for (var monthStr in prayerYearData.keys) {
      for (var dayData in prayerYearData[monthStr]!) {
        final int month = int.parse(monthStr);
        final int day = int.parse(dayData.date.gregorian.day);
        final date = DateTime(_focusedDay.year, month, day);
        prayerPerDay[date] = dayData.prayers.prayerList;
      }
    }
    return prayerPerDay;
  }

  @override
  void didUpdateWidget(covariant YearlyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings.city != oldWidget.settings.city ||
        widget.settings.country != oldWidget.settings.country ||
        widget.settings.method != oldWidget.settings.method) {
      assignPrayerYear().then((pPD) {
        _selectedPrayers.value = pPD[DateUtils.dateOnly(_selectedDay)]!;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _selectedPrayers.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    assignPrayerYear().then((pPD) {
      _selectedPrayers = ValueNotifier(pPD[DateUtils.dateOnly(_selectedDay)]!);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        if (picked != null &&
                            !isSameDay(picked, _selectedDay)) {
                          bool isSameYear = _focusedDay.year == picked.year;
                          setState(() => _focusedDay = _selectedDay = picked);
                          !isSameYear ? await assignPrayerYear() : null;
                          _selectedPrayers.value =
                              prayerPerDay[DateUtils.dateOnly(_selectedDay)]!;
                        }
                      },
                      child: Text(
                        '${DateHelper.monthsAr[day.month - 1]} ${day.year}',
                      ),
                    );
                  },
                ),
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
                        prayerPerDay[DateUtils.dateOnly(selectedDay)]!;
                  }
                },
                onPageChanged: (focusedDay) async {
                  bool isSameYear = _focusedDay.year == focusedDay.year;
                  _focusedDay = focusedDay;
                  !isSameYear ? await assignPrayerYear() : null;
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (cF) => setState(() => _calendarFormat = cF),
              ),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: _selectedPrayers,
                builder: (context, value, child) => PrayerListView(
                  prayerList: value,
                  is24H: widget.settings.is24H,
                  tileHeight: MediaQuery.sizeOf(context).height / 16,
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('Unexpected error.')); // Fallback
        }
      },
    );
  }
}
