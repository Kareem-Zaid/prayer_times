import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_day_model.dart';
import 'package:prayer_times/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         final prayerDay = await ApiService.getPrayerDay(
        //           dateDDMMYYYY: '27-08-2024',
        //           city: 'Jazan',
        //           country: 'Saudi Arabia',
        //         );
        //         debugPrint(
        //             'PrayerDay: ${prayerDay.data.date.hijri.monthAr.toString()}');
        //       },
        //       icon: const Icon(Icons.download))
        // ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('مواقيت الصلاة'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        // backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        onPressed: _incrementCounter,
        tooltip: 'مسبحة',
        child:
            Text('$_counter', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: FutureBuilder(
        future: ApiService.getPrayerDay(
            dateDDMMYYYY: '28-08-2024', city: 'Jazan', country: 'Saudi Arabia'),
        builder: (BuildContext context, AsyncSnapshot<PrayerDay> snapshot) {
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
                            onPressed: () {
                              DatePickerDialog(
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now(),
                              );
                            },
                            icon: Icon(Icons.calendar_month)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Text('الفجر'),
                          trailing: Text(prayers.fajr),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Text('الشروق'),
                          trailing: Text(prayers.sunrise),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Text('الظهر'),
                          trailing: Text(prayers.dhuhr),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Text('العصر'),
                          trailing: Text(prayers.asr),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Text('المغرب'),
                          trailing: Text(prayers.maghrib),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Text('العشاء'),
                          trailing: Text(prayers.isha),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
