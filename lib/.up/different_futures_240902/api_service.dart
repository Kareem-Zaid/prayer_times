import 'dart:convert';
import 'package:flutter/material.dart'; // for "debugPrint"
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:prayer_times/geocoding_model.dart';
import 'package:prayer_times/prayer_day_model.dart';

class ApiService {
  // Forward Geocoding API request
  static Future<Geocoding> getCoordinatesByAddress(
      String city, String country) async {
    await dotenv.load(); // Loads the default .env file from the root directory
    String apiKey = dotenv.env['API_KEY']!;
    final uri = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?key=$apiKey&q=$city%2C+$country');

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

  static Future<PrayerDay> getPrayerDay({
    required DateTime dateTime,
    required String city,
    required String country,
    int? method,
  }) async {
    const String baseUrl = 'https://api.aladhan.com/v1';
    Geocoding geocoding = await getCoordinatesByAddress(city, country);
    String dateDDMMYYYY = formatDate(dateTime);
    double lat = geocoding.results.first.geometry.lat; // WOW!
    double lng = geocoding.results.first.geometry.lng; // lssa mostagadd b2a :D
    String methodP = method != null ? '&method=$method' : '';
    final url = Uri.parse(
        '$baseUrl/timings/$dateDDMMYYYY?latitude=$lat&longitude=$lng$methodP');
    // url.replace(queryParameters: {}); // ... si tu veux add query parameters separately
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['code'] == 200) {
          debugPrint(
              'responseBody: ${responseBody['data']['date']['gregorian'].toString()}');
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
