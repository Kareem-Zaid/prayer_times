import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_day_model.dart';
import 'package:prayer_times/api_service.dart';
import 'package:prayer_times/prayer_day_future_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      floatingActionButton: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Positioned(
            bottom: 73,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => setState(() => _counter = 0),
              tooltip: 'تصفير',
              child: const Icon(Icons.restart_alt),
            ),
          ),
          Positioned(
            height: 77,
            width: 77,
            bottom: 0,
            child: FloatingActionButton.large(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              onPressed: () => setState(() => _counter++),
              tooltip: 'مسبحة',
              child: _counter == 0
                  ? Image.asset('assets/images/beads.png', height: 50)
                  : Text('$_counter',
                      style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
        ],
      ),
      body: PrayerDayFutureBuilder(prayerFuture: prayerFuture),
    );
  }
}
