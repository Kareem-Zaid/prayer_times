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

  late Future<PrayerDay> prayerFuture;
  @override
  void initState() {
    prayerFuture = ApiService.getPrayerDay(
        dateDDMMYYYY: '28-08-2024', city: 'Jazan', country: 'Saudi Arabia');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('مواقيت الصلاة'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'مسبحة',
        child:
            Text('$_counter', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: FutureBuilder(
        future: prayerFuture,
        builder: (BuildContext context, AsyncSnapshot<PrayerDay> snapshot) {
          final prayers = snapshot.data!.data.timings;
          final hijri = snapshot.data!.data.date.hijri;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: Text(
                              '${hijri.day} ${hijri.monthAr} ${hijri.year}')),
                      Expanded(child: Text(hijri.weekdayAr)),
                      Expanded(
                        child: ListTile(
                          leading: IconButton(
                              onPressed: () {
                                DatePickerDialog(
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now(),
                                );
                              },
                              icon: const Icon(Icons.calendar_month)),
                          title: Text(DateTime.now().toString()),
                        ),
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
          }
        },
      ),
    );
  }
}
