import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:prayer_times/geocoding_model.dart';
import 'prayer_day_model.dart';

class ApiService {
  // Forward Geocoding API request
  static Future<Geocoding> getCoordinatesByAddress(
      String city, String country) async {
    await dotenv.load(); // Loads the default .env file from the root directory
    String apiKey = dotenv.env['API_KEY']!;
    // comma + space = "%2C+"
    final uri = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?key=$apiKey&q=$city%2C+$country');
    debugPrint('Uri: $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final Status geoStatus = Geocoding.fromJson(responseBody).status;
        // final int geoStatusCode = Geocoding.fromJson(responseBody).status.code;
        // if (responseBody['code'] == 200) { // Different than PrayerDay's
        // Using nested-class 'code' property is less error-prone than map's nested key 'code' (https://chatgpt.com/c/636c9b65-7d4f-4ba7-9a1f-71967b24bcbf)
        if (geoStatus.code == 200) {
          debugPrint('responseBody: ${responseBody.toString()}');
          return Geocoding.fromJson(responseBody);
        } else {
          throw Exception(
              'getCoordinatesByAddress API logic exception is: ${geoStatus.code} | Message: ${geoStatus.message}');
          // throw Exception('getCoordinatesByAddress API logic exception is: ${responseBody['code']} | Message: ${responseBody['message']}');
        }
      } else {
        throw Exception(
            'getCoordinatesByAddress HTTP request exception is: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<PrayerDay> getPrayerDay({
    required String dateDDMMYYYY,
    required String city,
    required String country,
    int? method,
  }) async {
    /* static */ const String baseUrl = 'https://api.aladhan.com/v1';
    Geocoding geocoding = await getCoordinatesByAddress(city, country);
    // double? lat, lng; // todo: remove NULLABLE or handle it
    double lat = geocoding.results.first.geometry.lat; // WOW!
    double lng = geocoding.results.first.geometry.lng; // lssa mostagadd b2a :D
    String methodP = method != null ? '&method=$method' : '';
    final url = Uri.parse(
        '$baseUrl/timings/$dateDDMMYYYY?latitude=$lat&longitude=$lng$methodP');
    // url.replace(queryParameters: {}); // ... in case you want to add query parameters separately (https://chatgpt.com/c/3a8b6e51-0bd6-4dbe-9f23-1e34f939c237)
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        // final prayerDay = PrayerDay.fromJson(responseBody);
        if (responseBody['code'] == 200) {
          debugPrint('responseBody: ${responseBody.toString()}');
          // debugPrint('Future<PrayerDay> is: ${PrayerDay.fromJson(responseBody).toString()}');
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
      debugPrint(e.toString());
      rethrow;
    }
  }
}
