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

  DateTime parseTime(String time, DateTime today) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(today.year, today.month, today.day, hour, minute);
  }

  void getNextPrayer() {
    final DateTime now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly =
        DateTime(widget.date.year, widget.date.month, widget.date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      for (var i = 0; i < widget.prayers.prayerList.length; i++) {
        final dateTime1 = parseTime(widget.prayers.prayerList[i].time, now);
        final dateTime2 =
            parseTime(widget.prayers.prayerList[(i + 1) % 6].time, now);

        if (dateTime1.isBefore(now) && dateTime2.isAfter(now)) {
          nextPrayer = widget.prayers.prayerList[(i + 1) % 6];
          break;
        }
      }

      // Special case for Fajr
      if (nextPrayer == null) {
        final dateTime1 = parseTime(widget.prayers.prayerList[5].time, now);
        final dateTime2 = parseTime(widget.prayers.prayerList[0].time, now);

        if (dateTime1.isBefore(now) || dateTime2.isAfter(now)) {
          nextPrayer = widget.prayers.prayerList[0]; // Next prayer is Fajr
        }
      }
    }
    debugPrint('After-loop next prayer: ${nextPrayer?.name}');
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
