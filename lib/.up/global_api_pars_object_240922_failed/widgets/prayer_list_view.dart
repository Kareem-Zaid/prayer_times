import 'package:flutter/material.dart';
import 'package:prayer_times/models/prayer_day.dart';
import 'package:prayer_times/utils/string_extensions.dart';

class PrayerListView extends StatelessWidget {
  const PrayerListView({super.key, required this.prayers, required this.is24H});

  final Prayers prayers;
  final bool is24H;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        itemCount: prayers.prayerList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Text(prayers.prayerList[index].name),
              trailing: Text(
                is24H
                    ? prayers.prayerList[index].time.toArNums()
                    : prayers.prayerList[index].time.to12H().toArNums(),
              ),
            ),
          );
        },
      ),
    );
  }
}
