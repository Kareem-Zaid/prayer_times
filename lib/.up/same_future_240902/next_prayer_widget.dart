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

  DateTime parseTime(String time, DateTime date) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  void getNextPrayer() {
    bool prayerAssigned = false;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    // final DateTime selectedDate = DateTime(widget.date.year, widget.date.month, widget.date.day);

    // if (!selectedDate.isAtSameMomentAs(today)) return; // Calculate next prayer only if the selected date is today
    for (var i = 0; i < widget.prayers.prayerList.length - 1; i++) {
      final DateTime currentPrayerTime =
          parseTime(widget.prayers.prayerList[i].time, today);
      final DateTime nextPrayerTime =
          parseTime(widget.prayers.prayerList[i + 1].time, today);

      if (now.isAfter(currentPrayerTime) && now.isBefore(nextPrayerTime)) {
        nextPrayer = widget.prayers.prayerList[i + 1];
        prayerAssigned = true;
        break;
      }
    }

    // Special Case: Transition from Isha to Fajr
    final DateTime ishaTime =
        parseTime(widget.prayers.prayerList[5].time, today);
    final DateTime fajrTime = parseTime(
        widget.prayers.prayerList[0].time, today.add(const Duration(days: 1)));

    if (!prayerAssigned && (now.isAfter(ishaTime) || now.isBefore(fajrTime))) {
      nextPrayer = widget.prayers.prayerList[0];
    }
    debugPrint('Next prayer: ${nextPrayer?.name}');
  }

  @override
  Widget build(BuildContext context) {
    getNextPrayer();
    // DateTime? nowSet;
    // setState(() => nowSet = DateTime.now());

    return Column(
      children: [
        // Text('Current time: ${nowSet!.toIso8601String()}'),
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
      ],
    );
  }
}
