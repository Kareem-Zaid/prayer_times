extension StringExtensions on String {
  String toArNums() {
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

    // return this.split('').map((char) {
    // `this` is implicit here; it refers to the instance on which the method is called
    return split('').map((char) {
      return englishToArabicDigits[char] ?? char;
    }).join('');
  }

  DateTime parseTime() {
    final now = DateTime.now();
    List<String> parts = [];
    int mins;
    if (/* this. */ length == 5 && contains(':')) {
      parts = /* this. */ split(':');
      mins = int.parse(parts[1]);
    } else if (length > 5 && contains(':')) {
      parts = split(':');
      mins = int.parse(parts[1].substring(0, 2));
    } else {
      throw Exception('Invalid time format');
    }
    final hours = int.parse(parts[0]);

    return DateTime(now.year, now.month, now.day, hours, mins);
  }

  String to12H() {
    String time12H;
    final DateTime hourMin24 = parseTime();
    final int h = hourMin24.hour;
    final int m = hourMin24.minute;
    final String mStr = m.toString().padLeft(2, '0');

    switch (h) {
      case 0:
        time12H = '12:$mStr ص';
        break;
      case >= 1 && <= 11:
        time12H = '$h:$mStr ص';
        break;
      case 12:
        time12H = '12:$mStr م';
        break;
      case >= 13 && <= 23:
        time12H = '${h - 12}:$mStr م';
        break;
      default:
        time12H = "Invalid time input";
    }
    return time12H;
  }

  String omit24HTz() {
    // Either split and use 1st (time) part, or replace 2nd (time zone) part with ""
    List<String> parts = split(' (');
    String timeOnly = parts[0];
    return timeOnly;
  }
}

// int toInt() => int.parse(this);
