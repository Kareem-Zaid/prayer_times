import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_day_model.dart';
import 'package:prayer_times/utils.dart';

class NextPrayer extends StatefulWidget {
  const NextPrayer({super.key, required this.nextPrayer});

  final Prayer? nextPrayer;

  @override
  State<NextPrayer> createState() => _NextPrayerState();
}

class _NextPrayerState extends State<NextPrayer> {
  @override
  Widget build(BuildContext context) {
    final Duration eta = Utils.nextPrayerEta(widget.nextPrayer!);
    final int hours = eta.inHours;
    final int minutes = eta.inMinutes.remainder(60);
    // final int minutes = eta.inMinutes % 60; // Same as using "inMinutes.remainder(60)"
    final int seconds = eta.inSeconds.remainder(60);
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
            leading: Text(widget.nextPrayer?.name ?? '...'),
            trailing: Text(widget.nextPrayer?.time ?? '...'),
          ),
        ),
        Text(
          'بعد $hours {ساعات} و$minutes دقيقة',
          style: const TextStyle(fontSize: 20),
        ),
        Text('Seconds: $seconds'),
      ],
    );
  }
}
