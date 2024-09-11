import 'package:flutter/material.dart';
import 'package:prayer_times/api_service.dart';
import 'package:prayer_times/models/prayer_day.dart';
import 'package:prayer_times/prayer_list_view.dart';
import 'package:prayer_times/utils.dart';
import 'package:prayer_times/next_prayer.dart';

class PrayerFutBuilder extends StatefulWidget {
  const PrayerFutBuilder({super.key, required this.apiPars});
  final ApiPars apiPars;

  @override
  State<PrayerFutBuilder> createState() => _PrayerFutBuilderState();
}

class _PrayerFutBuilderState extends State<PrayerFutBuilder> {
  late Future<PrayerDay> prayerFuture;
  DateTime date = Utils.now;
  Prayer? nextPrayer;

  void assignPrayerDay() {
    prayerFuture = ApiService.getPrayerDay(date: date, apiPars: widget.apiPars);
    debugPrint('City inside API call: ${widget.apiPars.city}');
  }

  @override
  void didUpdateWidget(covariant PrayerFutBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.apiPars.country != oldWidget.apiPars.country ||
    //     widget.apiPars.city != oldWidget.apiPars.city ||
    //     widget.apiPars.method != oldWidget.apiPars.method) {
    //   assignPrayerDay();
    // }
    if (widget.apiPars.hasChanged(oldWidget.apiPars)) {
      assignPrayerDay();
    }
  }

  @override
  void initState() {
    assignPrayerDay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: prayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Error
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data received.')); // No data
        } else if (snapshot.hasData) {
          final prayers = snapshot.data!.data.prayers;
          final hijri = snapshot.data!.data.date.hijri;
          nextPrayer = Utils.getNextPrayer(
              prayers: prayers, date: date, nextPrayer: nextPrayer);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                NextPrayer(nextPrayer: nextPrayer),
                const SizedBox(height: 30),
                Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('${hijri.day} ${hijri.monthAr} ${hijri.year}'),
                        Text(hijri.weekdayAr),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'اختيار التاريخ',
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: Utils.now,
                                  lastDate: DateTime(Utils.now.year + 62),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    date = selectedDate;
                                    assignPrayerDay();
                                  });
                                }
                                debugPrint('Date after selection: $date');
                              },
                              icon: const Icon(Icons.calendar_month),
                            ),
                            Text(ApiService.formatDate(date)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                PrayerListView(prayers: prayers),
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
