import 'package:flutter/material.dart';
import 'package:prayer_times/api_service.dart';
import 'package:prayer_times/prayer_day_model.dart';
import 'prayer_day_list_view.dart';

class PrayerDayFutureBuilder extends StatefulWidget {
  const PrayerDayFutureBuilder({super.key});

  @override
  State<PrayerDayFutureBuilder> createState() => _PrayerDayFutureBuilderState();
}

class _PrayerDayFutureBuilderState extends State<PrayerDayFutureBuilder> {
  String formatDate(DateTime date) {
    // setState(() {});
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day-$month-$year';
  }

  late Future<PrayerDay> prayerFuture;
  DateTime date = DateTime.now();

  @override
  void initState() {
    prayerFuture = ApiService.getPrayerDay(
      dateDDMMYYYY: formatDate(date), // This implies a specific format
      city: 'Jazan', // City picker
      country: 'Saudi Arabia', // Country picker
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // If initState doesn't handle changes according to selectedDate, we may use that below
    // final Future<PrayerDay> prayerFuture = ApiService.getPrayerDay(dateDDMMYYYY: '28-08-2024', city: 'Jazan', country: 'Saudi Arabia');
    return FutureBuilder(
      // future: ApiService.getPrayerDay(dateDDMMYYYY: 'dateDDMMYYYY', city: 'city', country: 'country'), [1]
      // Counter state change & hot reload kept rebuilding FutureBuilder when the API request was called directly inside future property [1]. But after defining a pre-assigned variable for that call, it's is not rebuilt. [2]
      future: prayerFuture, // [2]
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}')); // Error occurred
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data received.')); // No data
        } else if (snapshot.hasData) {
          final prayers = snapshot.data!.data.timings;
          final hijri = snapshot.data!.data.date.hijri;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
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
                              // initialDate: selectedDate ?? DateTime.now(),
                              initialDate: date,
                              firstDate: DateTime.now(),
                              // currentDate: DateTime.now(),
                              // lastDate: DateTime(2101),
                              // lastDate: DateTime.now().add(const Duration(days: 365 * 62)),
                              lastDate: DateTime(DateTime.now().year + 62),
                              // initialDatePickerMode: DatePickerMode.day
                            );
                            if (selectedDate != null) {
                              setState(() => date = selectedDate);
                            }
                            // DatePickerDialog(firstDate: DateTime.now(), lastDate: DateTime.now());
                            debugPrint('Date after selection: $date');
                            // debugPrint('dateOnly: ${DateUtils.dateOnly(DateTime.now())}');
                          },
                          icon: const Icon(Icons.calendar_month),
                        ),
                        // Text(formatDate(selectedDate ?? DateTime.now())),
                        Text(formatDate(date)),
                        // Text(DateUtils.dateOnly(DateTime.now()).toString()), // 2024-08-30 00:00:00.000
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
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
