import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_day_model.dart';

class Utils {
  // static final DateTime now = DateTime.now(); // Doesn't update time on hot reload
  // static DateTime now = DateTime.now(); // Doesn't update time on hot reload either
  static DateTime get now => DateTime.now();
  static final DateTime today = DateTime(now.year, now.month, now.day);

  static DateTime parseTime(String strTime) {
    final parts = strTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(today.year, today.month, today.day, hour, minute);
  }

  // This method has to have a return, so that we can update the state and use it in 'PrayerDayFutureBuilder'.
  // It can be void only if we place it in 'PrayerDayFutureBuilder', where 'nextPrayer' value is updated automatically without passing it as a parameter.
  static Prayer getNextPrayer({
    required Prayers prayers,
    required DateTime date,
    required Prayer? nextPrayer,
  }) {
    bool prayerAssigned = false;

    final DateTime selectedDate = DateTime(date.year, date.month, date.day);

    // Calculate next prayer only if the selected date is today
    if (!selectedDate.isAtSameMomentAs(today)) return nextPrayer!;
    for (var i = 0; i < prayers.prayerList.length - 1; i++) {
      final DateTime currentPrayerTime = parseTime(prayers.prayerList[i].time);
      final DateTime nextPrayerTime = parseTime(prayers.prayerList[i + 1].time);

      if (now.isAfter(currentPrayerTime) && now.isBefore(nextPrayerTime)) {
        nextPrayer = prayers.prayerList[i + 1];
        prayerAssigned = true;
        break;
      }
    }

    // Special Case: Transition from Isha to Fajr
    final DateTime ishaTime = parseTime(prayers.prayerList[5].time);
    final DateTime fajrTime =
        parseTime(prayers.prayerList[0].time).add(const Duration(days: 1));

    if (!prayerAssigned && (now.isAfter(ishaTime) || now.isBefore(fajrTime))) {
      nextPrayer = prayers.prayerList[0];
    }
    debugPrint('Next prayer: ${nextPrayer?.name}');
    return nextPrayer!;
  }

  static Duration nextPrayerEta(Prayer nextPrayer) {
    DateTime nextPrayerTime = parseTime(nextPrayer.time);

    if (now.isAfter(nextPrayerTime) && nextPrayer.name == 'الفجر') {
      nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
    }

    final difference = nextPrayerTime.difference(now);
    return difference;
  }
}
