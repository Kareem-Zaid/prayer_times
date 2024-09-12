import 'package:flutter/material.dart';
import 'package:prayer_times/api_service.dart';
import 'package:prayer_times/models/prayer_day.dart';
import 'package:prayer_times/prayer_list_view.dart';
import 'package:prayer_times/utils.dart';
import 'package:prayer_times/next_prayer.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class PrayerFutBuilder extends StatefulWidget {
  const PrayerFutBuilder({
    super.key,
    required this.country,
    required this.city,
    required this.method,
  });
  // final ApiPars apiPars;
  final Country? country;
  final City? city;
  final int? method;

  @override
  State<PrayerFutBuilder> createState() => _PrayerFutBuilderState();
}

class _PrayerFutBuilderState extends State<PrayerFutBuilder> {
  late Future<PrayerDay> prayerFuture;
  DateTime date = Utils.now;
  Prayer? nextPrayer;

  void assignPrayerDay() {
    prayerFuture = ApiService.getPrayerDay(
      date: date,
      apiPars: ApiPars(
        country: widget.country,
        city: widget.city,
        method: widget.method,
      ),
    );
    // debugPrint('City inside API call: ${widget.apiPars.city}');
  }

  @override
  void didUpdateWidget(covariant PrayerFutBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('FutBuilder old-widget City: ${oldWidget.city?.nameEn}');
    debugPrint('FutB current-widget City: ${widget.city?.nameEn}');

    if (widget.country != oldWidget.country ||
        widget.city != oldWidget.city ||
        widget.method != oldWidget.method) {
      assignPrayerDay();
    }
    // if (widget.apiPars != oldWidget.apiPars) assignPrayerDay();
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
