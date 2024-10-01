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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: prayerList.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: tileHeight,
          child: Card(
            child: ListTile(
              leading: Text(prayerList[index].name),
              trailing: Text(
                is24H
                    ? prayerList[index].time.omit24HTz().toArNums()
                    : prayerList[index].time.to12H().toArNums(),
              ),
            ),
          ),
        );
      },
    );
  }
}
