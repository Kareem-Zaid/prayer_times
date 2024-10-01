import 'dart:convert';
import 'package:flutter/material.dart'; // for "debugPrint"
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:prayer_times/models/api_pars.dart';
import 'package:prayer_times/models/geocoding.dart';
import 'package:prayer_times/models/prayer_day.dart';

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

  static const String baseUrl = 'https://api.aladhan.com/v1';
  static Future<PrayerDay> getPrayerDay(
      {required DateTime date, required ApiPars apiPars}) async {
    final String countryEn = apiPars.country?.nameEn ?? 'Saudi Arabia';
    final String cityEn = apiPars.city?.nameEn ?? 'Jazan';
    final String methodStr =
        apiPars.method?.index != null && apiPars.method?.index != -1
            ? '&method=${apiPars.method?.index}'
            : '';
    final String dateDDMMYYYY = formatDate(date);
    final Geocoding geocoding = await forGeocoding(cityEn, countryEn);
    final double lat = geocoding.results.first.geometry.lat; // WOW!
    final lng = geocoding.results.first.geometry.lng; // lssa mostagadd b2a :D
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

  /* Future<PrayerMonth> */ getPrayerMonth(
      {required DateTime date, required ApiPars apiPars}) async {
    // final String month = date.month.toString().padLeft(2, '0');
    final String url = '$baseUrl/calendar/${date.year}/${date.month}?';
    final Uri uri = Uri.parse(url);
    final http.Response response = await http.get(uri);
    return;
  }
}
