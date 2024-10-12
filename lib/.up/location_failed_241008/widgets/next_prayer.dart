import 'package:flutter/material.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/services/next_prayer_service.dart';
import 'package:prayer_times/utils/string_extensions.dart';

class NextPrayer extends StatefulWidget {
  const NextPrayer({super.key, required this.nextPrayer, required this.is24H});

  final Prayer nextPrayer;
  final bool is24H;

  @override
  State<NextPrayer> createState() => _NextPrayerState();
}

class _NextPrayerState extends State<NextPrayer> {
  // static DateTime get now => DateTime.now();

  @override
  Widget build(BuildContext context) {
    final Duration eta = NextPrayerService.nextPrayerEta(widget.nextPrayer);
    // final int seconds = eta.inSeconds.remainder(60);
    return Column(
      children: [
        const Text(
          'الصلاة القادمة إن شاء الله:',
          style: TextStyle(fontSize: 19),
        ),
        Card(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          child: ListTile(
            textColor: Theme.of(context).colorScheme.inversePrimary,
            leading: Text(widget.nextPrayer.name),
            // subtitle: Text(eta.abs().toString()),
            trailing: Text(
              widget.is24H
                  ? widget.nextPrayer.time.toArNums()
                  : widget.nextPrayer.time.to12H().toArNums(),
            ),
          ),
        ),
        Text(NextPrayerService.formatEtaText(eta).toArNums()),
        // Text('Seconds: $seconds'),
      ],
    );
  }
}
