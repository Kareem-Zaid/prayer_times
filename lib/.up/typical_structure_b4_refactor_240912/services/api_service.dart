import 'dart:convert';
import 'package:flutter/material.dart'; // for "debugPrint"
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:prayer_times/models/geocoding.dart';
import 'package:prayer_times/models/prayer_day.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class ApiService {
  // Forward Geocoding API request
  static Future<Geocoding> forGeocoding(String city, String country) async {
    await dotenv.load(); // Loads the default .env file from the root directory
    String apiKey = dotenv.env['API_KEY']!;
    final uri = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?key=$apiKey&q=$city%2C+$country');
    debugPrint('Geocoding API uri: $uri');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final Status geoStatus = Geocoding.fromJson(responseBody).status;
        if (geoStatus.code == 200) {
          return Geocoding.fromJson(responseBody);
        } else {
          throw Exception(
              'getCoordinatesByAddress API logic exception is: ${geoStatus.code} | Message: ${geoStatus.message}');
        }
      } else {
        throw Exception(
            'getCoordinatesByAddress HTTP request exception is: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getCoordinatesByAddress caught error: ${e.toString()}');
      rethrow;
    }
  }

  static String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day-$month-$year';
  }

  static Future<PrayerDay> getPrayerDay(
      {required DateTime date, required ApiPars apiPars}) async {
    const String baseUrl = 'https://api.aladhan.com/v1';
    final String countryEn = apiPars.country?.nameEn ?? 'Saudi Arabia';
    final String cityEn = apiPars.city?.nameEn ?? 'Jazan';
    final Geocoding geocoding = await forGeocoding(cityEn, countryEn);
    final String dateDDMMYYYY = formatDate(date);
    final double lat = geocoding.results.first.geometry.lat; // WOW!
    final lng = geocoding.results.first.geometry.lng; // lssa mostagadd b2a :D
    final String methodStr =
        apiPars.method?.index != null && apiPars.method?.index != -1
            ? '&method=${apiPars.method?.index}'
            : '';
    final url = Uri.parse(
        '$baseUrl/timings/$dateDDMMYYYY?latitude=$lat&longitude=$lng$methodStr');
    // url.replace(queryParameters: {}); // ... si tu veux add query parameters separately
    debugPrint('getPrayerDay API uri: $url');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['code'] == 200) {
          // debugPrint('responseBody: ${responseBody['data']['date']['gregorian']}');
          debugPrint(
              'API GET return (fajrTime): ${PrayerDay.fromJson(responseBody).data.prayers.prayerList.firstOrNull?.time}');
          return PrayerDay.fromJson(responseBody);
        } else {
          throw Exception(
              'getPrayerDay API logic exception is: ${responseBody['code']} | Status: ${responseBody['status']} | Data: ${responseBody['data']}');
        }
      } else {
        throw Exception(
            'getPrayerDay HTTP request exception is: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getPrayerDay caught error: ${e.toString()}');
      rethrow;
    }
  }
}

class ApiPars {
  Country? country;
  City? city;
  Method? method;

  ApiPars({this.country, this.city, this.method});
}

class Method {
  int index;
  String name;

  Method({required this.index, required this.name});

  static Map<int, String> get methods => {
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Method && other.index == index);

  @override
  int get hashCode => index.hashCode;
}
