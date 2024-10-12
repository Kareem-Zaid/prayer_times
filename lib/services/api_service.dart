import 'dart:convert';
import 'package:flutter/material.dart'; // for "debugPrint"
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/models/geocoding.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/utils/date_helper.dart';

class ApiService {
  static Future<Geocoding> _fetchGeoApiData(String queryPars) async {
    await dotenv.load(); // Loads the default .env file from the root directory
    String apiKey = dotenv.env['API_KEY']!;
    const baseUrl = 'https://api.opencagedata.com/geocode/v1';
    final String url = '$baseUrl/json?key=$apiKey&q=$queryPars';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status']['code'] == 200) {
          return Geocoding.fromJson(responseBody);
        } else {
          throw Exception('Geocoding API logic exception is: '
              '${responseBody['status']['code']} | Message: ${responseBody['status']['message']}');
        }
      } else {
        throw Exception(
            'Geocoding HTTP request exception is: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      debugPrint('Geocoding API caught error: ${e.message}');
      rethrow;
    }
  }

  // Forward Geocoding API request
  static Future<Geocoding> _forGeocoding(String city, String country) async {
    final String queryPars = '$city%2C+$country';
    // final forGeocoding = await _fetchGeoApiData(queryPars);
    return await _fetchGeoApiData(queryPars);
  }

  // Reverse Geocoding API request
  static Future<Geocoding> revGeocoding(double lat, double lng) async {
    final String queryPars = '$lat%2C$lng';
    return await _fetchGeoApiData(queryPars);
  }

  static Future<String> _prepPrayerQueryPars(UserSettings apiPars) async {
    double lat;
    double lng;
    final String? countryEn = apiPars.country?.nameEn;
    final String? cityEn = apiPars.city?.nameEn;
    final String methodStr =
        apiPars.method?.index != null && apiPars.method?.index != -1
            ? '&method=${apiPars.method?.index}'
            : '';

    // If both city and country are provided, use them for geocoding
    if (cityEn != null && countryEn != null) {
      final Geocoding geocoding = await _forGeocoding(cityEn, countryEn);
      lat = geocoding.results.first.geometry.lat; // Use lat from geocoding
      lng = geocoding.results.first.geometry.lng;
    } else if (apiPars.lat != null && apiPars.lng != null) {
      // Get coordinates from geolocator "determinePosition()"
      lat = apiPars.lat!; // Use lat from position
      lng = apiPars.lng!;
    } else {
      // If position can't be determined, use fallback city/country for geocoding
      final Geocoding geocoding = await _forGeocoding('Cairo', 'Egypt');
      lat = geocoding.results.first.geometry.lat; // Fallback to default
      lng = geocoding.results.first.geometry.lng;
    }
    return 'latitude=$lat&longitude=$lng$methodStr';
  }

  static Future<Map<String, dynamic>> _fetchPrayerApiData(String path) async {
    const String baseUrl = 'https://api.aladhan.com/v1';
    final String url = baseUrl + path;
    final Uri uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['code'] == 200) {
          return responseBody;
        } else {
          throw Exception(
              'Prayer API logic exception is: ${responseBody['code']} | Status:'
              ' ${responseBody['status']} | Data: ${responseBody['data']}');
        }
      } else {
        throw Exception(
            'Prayer HTTP request exception is: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      debugPrint('Prayer API caught error: ${e.message}');
      rethrow;
    }
  }

  static Future<PrayerDay> getPrayerDay(
      {required DateTime date, required UserSettings apiPars}) async {
    final String dateDDMMYYYY = DateHelper.formatDate(date);
    final String path =
        '/timings/$dateDDMMYYYY?${await _prepPrayerQueryPars(apiPars)}';
    final Map<String, dynamic> responseBody = await _fetchPrayerApiData(path);
    return PrayerDay.fromJson(responseBody);
  }

  static Future<PrayerMonth> getPrayerMonth(
      {required DateTime date, required UserSettings apiPars}) async {
    final String path =
        '/calendar/${date.year}/${date.month}?${await _prepPrayerQueryPars(apiPars)}';
    final Map<String, dynamic> responseBody = await _fetchPrayerApiData(path);
    return PrayerMonth.fromJson(responseBody);
  }

  static Future<PrayerYear> getPrayerYear(
      {required DateTime date, required UserSettings apiPars}) async {
    final String path =
        '/calendar/${date.year}?${await _prepPrayerQueryPars(apiPars)}';
    final Map<String, dynamic> responseBody = await _fetchPrayerApiData(path);
    return PrayerYear.fromJson(responseBody);
  }
}
