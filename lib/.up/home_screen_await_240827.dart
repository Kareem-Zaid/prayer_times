import 'package:flutter/material.dart';
import 'api_service.dart';

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
        actions: [
          IconButton(
              onPressed: () async {
                final prayerDay = await ApiService.getPrayerDay(
                  dateDDMMYYYY: '27-08-2024',
                  city: 'Jazan',
                  country: 'Saudi Arabia',
                );
                debugPrint(
                    'PrayerDay: ${prayerDay.data.date.hijri.monthAr.toString()}');
              },
              icon: const Icon(Icons.download))
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('مواقيت الصلاة'),
      ),
      body: Center(
        child: ListView(
          children: const [
            Card(
              child: ListTile(leading: Text('الفجر'), trailing: Text('data')),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        // backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        onPressed: _incrementCounter,
        tooltip: 'مسبحة',
        child:
            Text('$_counter', style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}
