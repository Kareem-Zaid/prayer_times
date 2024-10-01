// import 'package:flutter/material.dart';
import 'package:prayer_times/models/prayer_day.dart';

class Helpers {
  // static final DateTime now = DateTime.now(); // Doesn't update time on rebuild (hot reload)
  // static DateTime now = DateTime.now(); // Doesn't update time on rebuild either
  static DateTime get now => DateTime.now(); // This one does update on rebuild
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
    final List<Prayer> fivePrayers = prayers.prayerList;
    fivePrayers.removeAt(1);
    for (var i = 0; i < fivePrayers.length - 1; i++) {
      // if (i == 0) continue;

      final DateTime currentPrayerTime = parseTime(fivePrayers[i].time);
      final DateTime nextPrayerTime = parseTime(fivePrayers[i + 1].time);

      if (now.isAfter(currentPrayerTime) && now.isBefore(nextPrayerTime)) {
        nextPrayer = fivePrayers[i + 1];
        prayerAssigned = true;
        break;
      }
    }

    // Special Case: Transition from Isha to Fajr
    final DateTime ishaTime = parseTime(fivePrayers.last.time);
    final DateTime fajrTime =
        parseTime(fivePrayers.first.time).add(const Duration(days: 1));

    if (!prayerAssigned && (now.isAfter(ishaTime) || now.isBefore(fajrTime))) {
      nextPrayer = fivePrayers.first;
    }
    // debugPrint('Next prayer: ${nextPrayer?.name}');
    return nextPrayer!;
  }

  static String convertToArabicNumbers(String inputNumber) {
    const englishToArabicDigits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    return inputNumber.split('').map((char) {
      return englishToArabicDigits[char] ?? char;
    }).join('');
  }
}
