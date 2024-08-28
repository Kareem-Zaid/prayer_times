class PrayerDay {
  final int code;
  final String status;
  final Data data;
  PrayerDay({required this.code, required this.status, required this.data});
  factory PrayerDay.fromJson(Map<String, dynamic> json) {
    return PrayerDay(
      code: json['code'],
      status: json['status'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final Timings timings;
  final Date date;
  // final Meta meta;

  Data({required this.timings, required this.date});
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      timings: Timings.fromJson(json['timings']), // Map<String, dynamic>
      date: Date.fromJson(json['date']), // Map<String, dynamic>
    );
  }
}

class Timings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      fajr: json['Fajr'],
      sunrise: json['Sunrise'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
    );

    // No need for 'toJson' method as the API endpoints offer GET requests only
  }
}

class Date {
  final Hijri hijri;
  Date({required this.hijri});
  factory Date.fromJson(Map<String, dynamic> json) {
    return Date(hijri: Hijri.fromJson(json['hijri']));
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
