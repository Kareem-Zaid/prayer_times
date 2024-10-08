import 'package:flutter/material.dart';
import 'package:prayer_times/models/api_pars.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/utils/date_helper.dart';
import 'package:prayer_times/utils/string_extensions.dart';
import 'package:prayer_times/widgets/prayer_list_view.dart';
import 'package:prayer_times/services/next_prayer_service.dart';
import 'package:prayer_times/widgets/next_prayer.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key, required this.apiPars});
  final ApiPars apiPars;

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  late Future<PrayerDay> _future;
  DateTime focusedDate = DateTime.now();
  Prayer? nextPrayer;

// Future<PrayerDay> get _future async => ApiService.getPrayerDay(date: focusedDate, apiPars: widget.apiPars);
// Using getter fails as it keeps rebuilding unnecessarily (on each setState of TabsScreen even)

  void assignPrayerDay() {
    _future = ApiService.getPrayerDay(
      date: focusedDate,
      apiPars: widget.apiPars,
    );
  }

  @override
  void didUpdateWidget(covariant DailyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // debugPrint('FutBuilder old-widget City: ${oldWidget.apiPars.city?.nameEn}');
    // debugPrint('FutB current-widget City: ${widget.apiPars.city?.nameEn}');
    if (widget.apiPars.city != oldWidget.apiPars.city ||
        widget.apiPars.country != oldWidget.apiPars.country ||
        widget.apiPars.method != oldWidget.apiPars.method) assignPrayerDay();
    // No need to add 'is24H' comparison/condition to the expression as its effect doesn't require a new API call
  }

  @override
  void initState() {
    assignPrayerDay();
    super.initState();
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
          final prayerList = snapshot.data!.datum.prayers.prayerList;
          final hijri = snapshot.data!.datum.date.hijri;
          nextPrayer = NextPrayerService.getNextPrayer(
            prayerList: prayerList,
            date: focusedDate,
            nextPrayer: nextPrayer,
          );
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                NextPrayer(
                    nextPrayer: nextPrayer!, is24H: widget.apiPars.is24H),
                const SizedBox(height: 20),
                Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('${hijri.day} ${hijri.monthAr} ${hijri.year}'
                            .toArNums()),
                        Text(hijri.weekdayAr),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'اختيار التاريخ',
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: focusedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year + 62),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    focusedDate = pickedDate;
                                    assignPrayerDay();
                                  });
                                }
                                debugPrint(
                                    'Date after selection: $focusedDate');
                              },
                              icon: const Icon(Icons.calendar_month),
                            ),
                            Text(DateHelper.formatDate(focusedDate).toArNums()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PrayerListView(
                  prayerList: prayerList,
                  is24H: widget.apiPars.is24H,
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('Unexpected error.')); // Fallback
        }
      },
    );
  }
}
