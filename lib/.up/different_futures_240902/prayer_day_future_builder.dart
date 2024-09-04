import 'package:flutter/material.dart';
import 'package:prayer_times/api_service.dart';
import 'package:prayer_times/prayer_day_model.dart';
import 'package:prayer_times/prayer_day_list_view.dart';

class PrayerDayFutureBuilder extends StatefulWidget {
  const PrayerDayFutureBuilder({super.key});

  @override
  State<PrayerDayFutureBuilder> createState() => _PrayerDayFutureBuilderState();
}

class _PrayerDayFutureBuilderState extends State<PrayerDayFutureBuilder> {
  late Future<PrayerDay> prayerFuture;
  DateTime date = DateTime.now();

  void assignPrayerDay() {
    prayerFuture = ApiService.getPrayerDay(
        dateTime: date, city: 'Jazan', country: 'Saudi Arabia');
  }

  @override
  void initState() {
    assignPrayerDay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // If initState doesn't handle changes according to selectedDate, we may use that below
    // final Future<PrayerDay> prayerFuture = ApiService.getPrayerDay(dateDDMMYYYY: '28-08-2024', city: 'Jazan', country: 'Saudi Arabia');
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year + 62),
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
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                PrayerDayListView(prayers: prayers),
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
