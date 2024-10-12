import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class UserSettings {
  Country? country;
  City? city;
  Method? method;
  bool is24H;
  bool isNotifsOn;
  double? lat;
  double? lng;

  UserSettings({
    this.country,
    this.city,
    this.method,
    this.is24H = false,
    this.isNotifsOn = true,
    this.lat,
    this.lng,
  });
}

class Method {
  final int index;
  final String name;

  const Method({required this.index, required this.name});

  static List<Method> get methodList => Method.methods.entries
      .map((x) => Method(index: x.key, name: x.value))
      .toList();

  static const Map<int, String> methods = {
    0: 'Jafari / Shia Ithna-Ashari',
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America',
    3: 'Muslim World League',
    4: 'Umm Al-Qura University, Makkah',
    5: 'Egyptian General Authority of Survey',
    7: 'Institute of Geophysics, University of Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Majlis Ugama Islam Singapura, Singapore',
    12: 'Union Organization islamic de France',
    13: 'Diyanet İşleri Başkanlığı, Turkey',
    14: 'Spiritual Administration of Muslims of Russia',
    15: 'Moonsighting Committee Worldwide',
    16: 'Dubai (experimental)',
    17: 'Jabatan Kemajuan Islam Malaysia (JAKIM)',
    18: 'Tunisia',
    19: 'Algeria',
    20: 'KEMENAG - Kementerian Agama Republik Indonesia',
    21: 'Morocco',
    22: 'Comunidade Islamica de Lisboa',
    23: 'Ministry of Awqaf, Islamic Affairs and Holy Places, Jordan',
  };

  // https://chatgpt.com/c/66e25a12-e108-8007-ba4d-fd95818587ed
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Method && other.index == index);

  @override
  int get hashCode => index.hashCode;
}
