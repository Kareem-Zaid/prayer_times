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
  // final Prayers timings;
  final Prayers prayers;
  final Date date;
  // final Meta meta;

  Data({required this.prayers, required this.date});
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
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
