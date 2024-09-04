import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_day_model.dart';
import 'prayer_day_list_view.dart';

class PrayerDayFutureBuilder extends StatelessWidget {
  const PrayerDayFutureBuilder({super.key, required this.prayerFuture});

  final Future<PrayerDay> prayerFuture;

  String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
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
                    // todo: Feels like 3 Expanded is redundant
                    Text('${hijri.day} ${hijri.monthAr} ${hijri.year}'),
                    Text(hijri.weekdayAr),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              DateTime? selectedDate;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Select Year'),
                                  content: SizedBox(
                                    width: double.minPositive,
                                    height: 250,
                                    child: YearPicker(
                                      // context: context,
                                      // initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2101),
                                      selectedDate: DateTime.now(),
                                      onChanged: (DateTime value) {
                                        selectedDate = value;
                                      },
                                      // initialDatePickerMode: DatePickerMode.day
                                    ),
                                  ),
                                ),
                              );
                              // DatePickerDialog(firstDate: DateTime.now(), lastDate: DateTime.now());
                              debugPrint('Selected date: $selectedDate');
                            },
                            icon: const Icon(Icons.calendar_month)),
                        Text(formatDate(DateTime.now())),
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
