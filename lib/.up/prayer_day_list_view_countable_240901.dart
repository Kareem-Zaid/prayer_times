import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_day_model.dart';

class PrayerDayListView extends StatelessWidget {
  const PrayerDayListView({super.key, required this.prayers});

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
      // child: ListView(
      //   shrinkWrap: true,
      //   // 'shrinkWrap': 'true' + 'Flexible' fits list to its elements
      //   // physics: const NeverScrollableScrollPhysics(),
      //   children: [
      //     Card(
      //       child: ListTile(
      //         leading: Text(prayers.fajr.name),
      //         trailing: Text(prayers.fajr.time),
      //       ),
      //     ),
      //     Card(
      //       child: ListTile(
      //         leading: Text(prayers.sunrise.name),
      //         trailing: Text(prayers.sunrise.time),
      //       ),
      //     ),
      //     Card(
      //       child: ListTile(
      //         leading: Text(prayers.dhuhr.name),
      //         trailing: Text(prayers.dhuhr.time),
      //       ),
      //     ),
      //     Card(
      //       child: ListTile(
      //         leading: Text(prayers.asr.name),
      //         trailing: Text(prayers.asr.time),
      //       ),
      //     ),
      //     Card(
      //       child: ListTile(
      //         leading: Text(prayers.maghrib.name),
      //         trailing: Text(prayers.maghrib.time),
      //       ),
      //     ),
      //     Card(
      //       child: ListTile(
      //         leading: Text(prayers.isha.name),
      //         trailing: Text(prayers.isha.time),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
