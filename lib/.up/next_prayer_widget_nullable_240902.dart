import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_day_model.dart';

class NextPrayer extends StatefulWidget {
  const NextPrayer({super.key, required this.prayers, required this.date});

  final Prayers prayers;
  final DateTime date;

  @override
  State<NextPrayer> createState() => _NextPrayerState();
}

class _NextPrayerState extends State<NextPrayer> {
  Prayer? nextPrayer;

  void getNextPrayer() {
    final DateTime now = DateTime.now();
    final dateOnly =
        DateTime(widget.date.year, widget.date.month, widget.date.day);
    final nowDate = DateTime(now.year, now.month, now.day);
    // debugPrint('Selected date: $dateOnly');
    // debugPrint('Now date: $nowDate');
    try {
      if (dateOnly.isAtSameMomentAs(nowDate)) {
        debugPrint('Dates are equal');
        for (var i = 0; i < widget.prayers.prayerList.length; i++) {
          final time1 = widget.prayers.prayerList[i].time.split(':');
          final hour1 = int.parse(time1[0]);
          final int min1 = int.parse(time1[1]);
          final dateTime1 = DateTime(now.year, now.month, now.day, hour1, min1);
          final time2 = widget.prayers.prayerList[i + 1].time.split(':');
          final int hour2 = int.parse(time2[0]);
          final min2 = int.parse(time2[1]);
          final dateTime2 = DateTime(now.year, now.month, now.day, hour2, min2);
          if (dateTime1.isBefore(now) && dateTime2.isAfter(now)) {
            nextPrayer = widget.prayers.prayerList[i + 1];
            // setState(() => nextPrayer = widget.prayers.prayerList[i + 1]);
          }
          if (i >= 4) break;
        }
        if (nextPrayer == null) {
          final time1 = widget.prayers.prayerList[5].time.split(':');
          final hour1 = int.parse(time1[0]);
          final int min1 = int.parse(time1[1]);
          final dateTime1 = DateTime(now.year, now.month, now.day, hour1, min1);
          final time2 = widget.prayers.prayerList[0].time.split(':');
          final int hour2 = int.parse(time2[0]);
          final min2 = int.parse(time2[1]);
          final dateTime2 = DateTime(now.year, now.month, now.day, hour2, min2);
          if (dateTime1.isBefore(now) || dateTime2.isAfter(now)) {
            // Special case for 'Fajr'
            nextPrayer = widget.prayers.prayerList[0];
            // setState(() => nextPrayer = widget.prayers.prayerList[0]);
          }
        }
        // return nextPrayer ?? Prayer(name: '...', time: '..:..'); // Loop failed
        debugPrint('After-loop next prayer: ${nextPrayer?.name}');
      }
    } on Exception catch (e) {
      debugPrint('Error: $e');
    }
    // throw Exception('Error: Dates are not equal'); // Not today
  }

  @override
  Widget build(BuildContext context) {
    getNextPrayer();
    return Column(
      children: [
        const Text(
          'الصلاة القادمة إن شاء الله:',
          style: TextStyle(fontSize: 20),
        ),
        Card(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          child: ListTile(
            textColor: Theme.of(context).colorScheme.inversePrimary,
            leading: Text(nextPrayer?.name ?? '...'),
            trailing: Text(nextPrayer?.time ?? '...'),
          ),
        ),
        const Text(
          'بعد ... ساعات و... دقيقة',
          style: TextStyle(fontSize: 20),
        ),
        // nextPrayer(),
      ],
    );
  }
}
