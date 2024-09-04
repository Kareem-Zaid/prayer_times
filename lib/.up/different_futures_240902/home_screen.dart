import 'package:flutter/material.dart';
import 'package:prayer_times/next_prayer_widget.dart';
// ignore: unused_import
import 'package:prayer_times/prayer_day_future_builder.dart';
import 'package:prayer_times/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NextPrayer(),
          PrayerDayFutureBuilder(),
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
    );
  }
}
