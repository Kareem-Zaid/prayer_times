// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/utils/string_extensions.dart';

class NextPrayerService {
  // static final DateTime now = DateTime.now(); // Doesn't update time on rebuild (hot reload)
  // static DateTime now = DateTime.now(); // Doesn't update time on rebuild either
  static DateTime get now => DateTime.now(); // This one does update on rebuild

  // This method has to have a return, so that we can update the state and use it in 'PrayerDayFutureBuilder'.
  // It can be void only if we place it in 'PrayerDayFutureBuilder', where 'nextPrayer' value is updated automatically without passing it as a parameter.
  static Prayer getNextPrayer({
    required List<Prayer> prayerList,
    required DateTime date,
    required Prayer? nextPrayer,
  }) {
    bool prayerAssigned = false;
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime selectedDate = DateTime(date.year, date.month, date.day);

    // Calculate next prayer only if the selected date is today
    // if (!selectedDate.isAtSameMomentAs(today)) return nextPrayer!;
    if (!DateUtils.isSameDay(selectedDate, today)) return nextPrayer!;
    final List<Prayer> fivePrayers = prayerList;
    fivePrayers.removeAt(1);
    for (var i = 0; i < fivePrayers.length - 1; i++) {
      // if (i == 0) continue;

      final DateTime currentPrayerTime = fivePrayers[i].time.parseTime();
      final DateTime nextPrayerTime = fivePrayers[i + 1].time.parseTime();

      if (now.isAfter(currentPrayerTime) && now.isBefore(nextPrayerTime)) {
        nextPrayer = fivePrayers[i + 1];
        prayerAssigned = true;
        break;
      }
    }

    // Special Case: Transition from Isha to Fajr
    final DateTime ishaTime = fivePrayers.last.time.parseTime();
    final DateTime fajrTime =
        fivePrayers.first.time.parseTime().add(const Duration(days: 1));

    if (!prayerAssigned && (now.isAfter(ishaTime) || now.isBefore(fajrTime))) {
      nextPrayer = fivePrayers.first;
    }
    // debugPrint('Next prayer: ${nextPrayer?.name}');
    return nextPrayer!;
  }

  static Duration nextPrayerEta(Prayer nextPrayer) {
    DateTime nextPrayerTime = nextPrayer.time.parseTime();

    if (now.isAfter(nextPrayerTime) && nextPrayer.name == 'الفجر') {
      nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
    }

    final difference = nextPrayerTime.difference(now);
    return difference;
  }

  static String formatEtaText(Duration eta) {
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
}
