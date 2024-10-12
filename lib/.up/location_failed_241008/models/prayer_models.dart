class PrayerYear {
  final int code;
  final String status;
  final Map<String, List<Datum>> yearData;

  PrayerYear(
      {required this.code, required this.status, required this.yearData});

  factory PrayerYear.fromJson(Map<String, dynamic> json) {
    return PrayerYear(
      code: json['code'],
      status: json['status'],
      yearData: Map.from(json['data']).map((k, v) {
        return MapEntry(
          k,
          List.from((v as List).map((datum) {
            return Datum.fromJson(datum);
          })),
        );
      }),
    );
  }
}

class PrayerMonth {
  final int code;
  final String status;
  final List<Datum> monthData;

  PrayerMonth(
      {required this.code, required this.status, required this.monthData});
  factory PrayerMonth.fromJson(Map<String, dynamic> json) {
    return PrayerMonth(
      code: json['code'],
      status: json['status'],
      monthData: List.from((json['data'] as List).map((datum) {
        return Datum.fromJson(datum);
      })),
    );
  }
}

class PrayerDay {
  final int code;
  final String status;
  final Datum datum;

  PrayerDay({required this.code, required this.status, required this.datum});
  factory PrayerDay.fromJson(Map<String, dynamic> json) {
    return PrayerDay(
      code: json['code'],
      status: json['status'],
      datum: Datum.fromJson(json['data']),
    );
  }
}

class Datum {
  // final Prayers timings;
  final Prayers prayers;
  final Date date;
  // final Meta meta;

  Datum({required this.prayers, required this.date});
  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      prayers: Prayers.fromJson(json['timings']), // Map<String, dynamic>
      date: Date.fromJson(json['date']), // Map<String, dynamic>
    );
  }
}

// class Timings { // Class name doesn't have to match the API json key
class Prayers {
  final Prayer fajr;
  final Prayer sunrise;
  final Prayer dhuhr;
  final Prayer asr;
  final Prayer maghrib;
  final Prayer isha;

  Prayers({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory Prayers.fromJson(Map<String, dynamic> json) {
    return Prayers(
      fajr: Prayer(name: 'الفجر', time: json['Fajr']),
      sunrise: Prayer(name: 'الشروق', time: json['Sunrise']),
      dhuhr: Prayer(name: 'الظهر', time: json['Dhuhr']),
      asr: Prayer(name: 'العصر', time: json['Asr']),
      maghrib: Prayer(name: 'المغرب', time: json['Maghrib']),
      isha: Prayer(name: 'العشاء', time: json['Isha']),
    );
  }

  // Method to return a list of all prayers
  List<Prayer> get prayerList {
    return [fajr, sunrise, dhuhr, asr, maghrib, isha];
  }

  // No need for 'toJson' method as the API endpoints offer GET requests only
}

class Prayer {
  final String name, time;
  Prayer({required this.name, required this.time});
}

class Date {
  final Gregorian gregorian;
  final Hijri hijri;
  Date({required this.gregorian, required this.hijri});
  factory Date.fromJson(Map<String, dynamic> json) {
    return Date(
      gregorian: Gregorian.fromJson(json['gregorian']),
      hijri: Hijri.fromJson(json['hijri']),
    );
  }
}

class Gregorian {
  final String day, date;

  Gregorian({required this.day, required this.date});

  factory Gregorian.fromJson(Map<String, dynamic> json) {
    return Gregorian(day: json['day'], date: json['date']);
  }
}

class Hijri {
  // final String date;
  // Hijri({required this.date});
  // factory Hijri.fromJson(Map<String, dynamic> json) =>
  //     Hijri(date: json['date']);
  // final int day; // Actually, it's not 'int' in the json. Match it, man!
  final String day;
  final String weekdayAr;
  final String monthAr;
  // final int year; // ~
  final String year;
  Hijri(
      {required this.day,
      required this.weekdayAr,
      required this.monthAr,
      required this.year});
  factory Hijri.fromJson(Map<String, dynamic> json) {
    return Hijri(
        day: json['day'],
        weekdayAr: json['weekday']['ar'], // [1]
        // Direct nest access, instead of creating new model classes [1]
        monthAr: json['month']['ar'], // [1]
        year: json['year']);
  }
}
