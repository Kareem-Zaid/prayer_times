import 'package:flutter/material.dart';
import 'package:prayer_times/models/api_pars.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/utils/date_helper.dart';
import 'package:prayer_times/widgets/prayer_list_view.dart';
import 'package:table_calendar/table_calendar.dart';

class YearlyScreen extends StatefulWidget {
  const YearlyScreen({super.key, required this.apiPars});
  final ApiPars apiPars;

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
  // bool _isLoading = false; // Flag to track if the year is being assigned

  Future<Map<DateTime, List<Prayer>>> assignPrayerYear() async {
    // API call + Map prayers per day (Create a yearly prayer map) + Assign prayer list as per selected day
    debugPrint('_focusedDay inside method: $_focusedDay');
    debugPrint('_selectedDay inside method: $_selectedDay');

    _future =
        ApiService.getPrayerYear(date: _focusedDay, apiPars: widget.apiPars);
    final PrayerYear prayerYear = await _future;
    final prayerYearData = prayerYear.yearData;
    for (var monthStr in prayerYearData.keys) {
      for (var dayData in prayerYearData[monthStr]!) {
        final int month = int.parse(monthStr);
        final int day = int.parse(dayData.date.gregorian.day);
        // final date = DateTime(_selectedDay.year, month, day); // Here's the mistake
        final date = DateTime(_focusedDay.year, month, day);
        prayerPerDay[date] = dayData.prayers.prayerList;
      }
    }
    debugPrint(
        'prayerPerDay inside method: ${prayerPerDay[DateUtils.dateOnly(_selectedDay)]}');
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
                        if (picked != null) {
                          // late bool isSameYear;
                          late bool isSameYear;
                          setState(() {
                            isSameYear = _focusedDay.year == picked.year;
                            _focusedDay = _selectedDay = picked;
                          });
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
                    // if (_isLoading) return;
                    debugPrint('selectedDay onDaySelected: $selectedDay');
                    debugPrint('prayerPerDay onDaySelected: ${prayerPerDay}');
                    debugPrint(
                        'prayerPerDay[_selectedDay] onDaySelected: ${prayerPerDay[DateUtils.dateOnly(_selectedDay)]}');
                    _selectedPrayers.value =
                        prayerPerDay[DateUtils.dateOnly(selectedDay)]!;
                  }
                },
                onPageChanged: (focusedDay) async {
                  bool isSameYear = _focusedDay.year == focusedDay.year;
                  _focusedDay = focusedDay;
                  // _isLoading = true;
                  !isSameYear ? await assignPrayerYear() : null;
                  // _isLoading = false;
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (cF) => setState(() => _calendarFormat = cF),
              ),
              ValueListenableBuilder(
                valueListenable: _selectedPrayers,
                builder: (context, value, child) => PrayerListView(
                  prayerList: value,
                  is24H: widget.apiPars.is24H,
                  tileHeight: MediaQuery.sizeOf(context).height / 16,
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
