import 'package:flutter/material.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/utils/string_extensions.dart';

class PrayerListView extends StatelessWidget {
  const PrayerListView({
    super.key,
    required this.prayerList,
    required this.is24H,
    this.tileHeight,
  });

  final List<Prayer> prayerList;
  final bool is24H;
  final double? tileHeight;

  @override
  Widget build(BuildContext context) {
    // Using Column inside a ListView.builder is better, as using another ListView.builder causes unwanted scroll behavior.
    // Wrapping Column by SingleChildScrollView doesn't have an effect on scrolling, unless I wrap it with SizedBox.
    return Column(
      children: [
        for (var prayer in prayerList)
          SizedBox(
            height: tileHeight,
            child: Card(
              child: ListTile(
                leading: Text(prayer.name),
                trailing: Text(
                  is24H
                      ? prayer.time.omit24HTz().toArNums()
                      : prayer.time.to12H().toArNums(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
