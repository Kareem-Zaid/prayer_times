import 'package:flutter/material.dart';
import 'package:prayer_times/models/prayer_day.dart';
import 'package:prayer_times/utils.dart';

class NextPrayer extends StatefulWidget {
  const NextPrayer({super.key, required this.nextPrayer});

  final Prayer? nextPrayer;

  @override
  State<NextPrayer> createState() => _NextPrayerState();
}

class _NextPrayerState extends State<NextPrayer> {
  // static DateTime get now => DateTime.now();
  Duration nextPrayerEta(Prayer nextPrayer) {
    final now = Utils.now;
    DateTime nextPrayerTime = Utils.parseTime(nextPrayer.time);

    if (now.isAfter(nextPrayerTime) && nextPrayer.name == 'الفجر') {
      nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
    }

    final difference = nextPrayerTime.difference(now);
    return difference;
  }

  String formatEtaText(Duration eta) {
    // Add 1 minute to handle rounding errors
    // eta = eta + const Duration(minutes: 1); // Can be shortened like below:
    if (eta.inSeconds.remainder(60) > 0) eta += const Duration(minutes: 1);
    final int hours = eta.inHours;
    final int minutes = eta.inMinutes.remainder(60);
    // final int minutes = eta.inMinutes % 60; // Same as using "inMinutes.remainder(60)"
    String hoursText;
    String minutesText;

    switch (hours) {
      case 0:
        hoursText = '';
        break;
      case 1:
        hoursText = 'ساعة';
        break;
      case 2:
        hoursText = 'ساعتين';
        break;
      case >= 3 && <= 10:
        hoursText = '$hours ساعات';
        break;
      case > 10:
        hoursText = '$hours ساعة';
        break;
      default:
        hoursText = '$hours ساعة';
    }

    switch (minutes) {
      case 0:
        minutesText = '';
        break;
      case 1:
        minutesText = 'دقيقة';
        break;
      case 2:
        minutesText = 'دقيقتين';
        break;
      case >= 3 && <= 10:
        minutesText = '$minutes دقائق';
        break;
      case > 10:
        minutesText = '$minutes دقيقة';
        break;
      default:
        minutesText = '$minutes دقيقة';
    }

    return 'بعد $hoursText${hoursText != '' && minutesText != '' ? ' و' : ''}$minutesText';
  }

  @override
  Widget build(BuildContext context) {
    final Duration eta = nextPrayerEta(widget.nextPrayer!);
    // final int seconds = eta.inSeconds.remainder(60);
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
        Text(Utils.convertToArabicNumbers(formatEtaText(eta)),
            style: const TextStyle(fontSize: 20)),
        // Text('Seconds: $seconds'),
      ],
    );
  }
}
