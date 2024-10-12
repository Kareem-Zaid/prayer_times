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
  State<YearlyScreen> createState() => YearlyScreenState();
}

class YearlyScreenState extends State<YearlyScreen> {
  static late Future<PrayerYear> _future;
  static DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, List<Datum>>? prayerYear;
  static final Map<DateTime, List<Prayer>> _prayerPerDay = {};
  late final ValueNotifier<List<Prayer>> _selectedPrayers;

  static Future<Map<DateTime, List<Prayer>>> assignPrayerYear(
      UserSettings settings) async {
    // API call + Map prayers per day (Create a yearly prayer map) + Assign prayer list as per selected day
    try {
      _future = ApiService.getPrayerYear(date: _focusedDay, apiPars: settings);
      final PrayerYear prayerYear = await _future;
      final prayerYearData = prayerYear.yearData;
      for (var monthStr in prayerYearData.keys) {
        for (var dayData in prayerYearData[monthStr]!) {
          final int month = int.parse(monthStr);
          final int day = int.parse(dayData.date.gregorian.day);
          final date = DateTime(_focusedDay.year, month, day);
          _prayerPerDay[date] = dayData.prayers.prayerList;
        }
      }
    } on Exception catch (e) {
      debugPrint('getPrayerYear caught error: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(settings.context).showSnackBar(const SnackBar(
            content: Text('''لم يتم تحميل بيانات مواقيت الصلاة السنوية..
يرجى التأكد من الاتصال بالإنترنت وتحديث الصفحة''')));
      });
    }
    return _prayerPerDay;
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
    assignPrayerYear(widget.settings).then((pPD) {
      _selectedPrayers =
          ValueNotifier(pPD[DateUtils.dateOnly(_selectedDay)] ?? []);
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
          return const Center(child: Text('''خطأ في تحميل البيانات...
يرجى التأكد من الاتصال بالإنترنت''', textAlign: TextAlign.center)); // Error
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data received.')); // No data
        } else if (snapshot.hasData) {
          prayerYear = snapshot.data!.yearData;
          _selectedPrayers.value =
              _prayerPerDay[DateUtils.dateOnly(_selectedDay)]!;
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
                          !isSameYear
                              ? await assignPrayerYear(widget.settings)
                              : null;
                          _selectedPrayers.value =
                              _prayerPerDay[DateUtils.dateOnly(_selectedDay)]!;
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
                pageJumpingEnabled: true,
                locale: 'ar',
                firstDay: DateTime(DateTime.now().year),
                lastDay: DateTime(DateTime.now().year + 62),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) async {
                  bool isSameYear = _focusedDay.year == selectedDay.year;
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    !isSameYear
                        ? await assignPrayerYear(widget.settings)
                        : null;
                    _selectedPrayers.value =
                        _prayerPerDay[DateUtils.dateOnly(selectedDay)]!;
                  }
                },
                onPageChanged: (focusedDay) async {
                  bool isSameYear = _selectedDay.year == focusedDay.year;
                  _focusedDay = focusedDay;
                  !isSameYear ? await assignPrayerYear(widget.settings) : null;
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (cF) => setState(() => _calendarFormat = cF),
                daysOfWeekHeight: MediaQuery.sizeOf(context).height / 32,
                rowHeight: MediaQuery.sizeOf(context).height / 22,
              ),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: _selectedPrayers,
                builder: (context, value, child) => PrayerListView(
                  prayerList: value,
                  is24H: widget.settings.is24H,
                  tileHeight: MediaQuery.sizeOf(context).height / 15,
                ),
              ),
              const Spacer(),
            ],
          );
        } else {
          return const Center(child: Text('Unexpected error.')); // Fallback
        }
      },
    );
  }
}
