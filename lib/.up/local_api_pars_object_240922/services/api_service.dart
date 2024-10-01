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
    const baseUrl = 'https://api.opencagedata.com/geocode/v1';
    final String url = '$baseUrl/json?key=$apiKey&q=$city%2C+$country';
    final uri = Uri.parse(url);
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
  static Future<String> prepQueryPars(ApiPars apiPars) async {
    final String countryEn = apiPars.country?.nameEn ?? 'Saudi Arabia';
    final String cityEn = apiPars.city?.nameEn ?? 'Jazan';
    final String methodStr =
        apiPars.method?.index != null && apiPars.method?.index != -1
            ? '&method=${apiPars.method?.index}'
            : '';
    final Geocoding geocoding = await forGeocoding(cityEn, countryEn);
    final double lat = geocoding.results.first.geometry.lat; // WOW!
    final lng = geocoding.results.first.geometry.lng; // lssa mostagadd b2a :D
    return 'latitude=$lat&longitude=$lng$methodStr';
  }

  static Future<Map<String, dynamic>> fetchApiData(Uri uri) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['code'] == 200) {
          return responseBody;
        } else {
          throw Exception(
              'API logic exception is: ${responseBody['code']} | Status: ${responseBody['status']} | Data: ${responseBody['data']}');
        }
      } else {
        throw Exception('HTTP request exception is: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Caught error: ${e.toString()}');
      rethrow;
    }
  }

  static Future<PrayerDay> getPrayerDay(
      {required DateTime date, required ApiPars apiPars}) async {
    final String dateDDMMYYYY = formatDate(date);
    final String url =
        '$baseUrl/timings/$dateDDMMYYYY?${await prepQueryPars(apiPars)}';
    final Uri uri = Uri.parse(url);
    final Map<String, dynamic> responseBody = await fetchApiData(uri);
    return PrayerDay.fromJson(responseBody);
  }

  static Future<PrayerMonth> getPrayerMonth(
      {required DateTime date, required ApiPars apiPars}) async {
    final String url =
        '$baseUrl/calendar/${date.year}/${date.month}?${await prepQueryPars(apiPars)}';
    final Uri uri = Uri.parse(url);
    final Map<String, dynamic> responseBody = await fetchApiData(uri);
    return PrayerMonth.fromJson(responseBody);
  }

  static Future<PrayerYear> getPrayerYear(
      {required DateTime date, required ApiPars apiPars}) async {
    final String url =
        '$baseUrl/calendar/${date.year}?${await prepQueryPars(apiPars)}';
    final Uri uri = Uri.parse(url);
    final Map<String, dynamic> responseBody = await fetchApiData(uri);
    return PrayerYear.fromJson(responseBody);
  }
}
