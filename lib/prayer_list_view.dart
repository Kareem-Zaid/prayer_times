import 'package:flutter/material.dart';
import 'package:prayer_times/models/prayer_day.dart';

class PrayerListView extends StatelessWidget {
  const PrayerListView({super.key, required this.prayers});

  final Prayers prayers;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        itemCount: prayers.prayerList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Text(prayers.prayerList[index].name),
              trailing: Text(prayers.prayerList[index].time),
            ),
          );
        },
      ),
    );
  }
}
