import 'package:flutter/material.dart';
import 'package:prayer_times/models/api_pars.dart';
import 'package:prayer_times/models/prayer_day.dart';
import 'package:prayer_times/services/api_service.dart';
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

  void assignPrayerYear() {
    _future = ApiService.getPrayerYear(
      date: _focusedDay,
      apiPars: widget.apiPars,
    );
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
          // final prayerYear = snapshot.data!.dataYear /* .values.toList() */;
          return TableCalendar(
            onHeaderTapped: (focusedDay) async {
              debugPrint('onHeaderTapped focusDay: $focusedDay');

              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _focusedDay, // Initiate at focused date
                firstDate: DateTime.now(), // Start for the picker
                lastDate: DateTime(DateTime.now().year + 62), // End year ~
                builder: (context, child) => child!,
                // Disable day selection by restricting selectable days
                // Allow only the first day of each month to be selectable
                // selectableDayPredicate: (DateTime day) => day.day == 1,
              );
              // https://chatgpt.com/c/66f1a75e-6880-8007-979b-ed7751d5fb12
              if (picked != null) {
                setState(() {
                  // Process the picked year and month here
                  _focusedDay = DateTime(
                      picked.year, picked.month); // Focus on the month & year
                });
              }

              // debugPrint('DateTime: ${DateTime(2024, 9, 24, 2, 10, 50)}');
              // debugPrint('DateTime.utc: ${DateTime.utc(2024, 9, 24, 2, 10, 50)}');
            },
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
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              debugPrint('onDaySelected selectedDay: $_selectedDay'); // Same...
              // debugPrint('onDaySelected focusedDay: $_focusedDay'); // ... same
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              debugPrint('onPageChanged focusedDay: ${_focusedDay.toString()}');
              // debugPrint('onPageChanged ISO: ${_focusedDay.toIso8601String()}');
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (cF) => setState(() => _calendarFormat = cF),
          );
        } else {
          return const Center(child: Text('Unexpected error.')); // Fallback
        }
      },
    );
  }
}
