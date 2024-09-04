import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_day_model.dart';

class PrayersListView extends StatelessWidget {
  const PrayersListView({
    super.key,
    required this.prayers,
  });

  final Timings prayers;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    );
  }
}
