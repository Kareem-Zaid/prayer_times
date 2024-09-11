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
    final methodP = apiPars.method != null ? '&method=${apiPars.method}' : '';
    final url = Uri.parse(
        '$baseUrl/timings/$dateDDMMYYYY?latitude=$lat&longitude=$lng$methodP');
    // url.replace(queryParameters: {}); // ... si tu veux add query parameters separately
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
  int? method;

  ApiPars({this.country, this.city, this.method});

  bool hasChanged(ApiPars other) {
    return country != other.country ||
        city != other.city ||
        method != other.method;
  }

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is ApiPars &&
  //         runtimeType == other.runtimeType &&
  //         city == other.city &&
  //         country == other.country &&
  //         method == other.method;

  // @override
  // int get hashCode => city.hashCode ^ country.hashCode ^ method.hashCode;
}
