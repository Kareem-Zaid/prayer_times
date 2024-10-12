import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times/models/geocoding.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class LocationService {
  Future<Position> determinePosition() async {
    debugPrint('determinePosition started');
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt the user to enable location services
      bool openedSettings = await Geolocator.openLocationSettings();
      if (!openedSettings) {
        return Future.error(
            'Location services are disabled and settings were not opened.');
      }

      // Recheck if location services are enabled after opening settings
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error(
            'Location services are still disabled after opening settings.');
      }
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Prompt the user to grant location permission
      bool openedSettings = await Geolocator.openAppSettings();
      if (!openedSettings) {
        return Future.error(
            'Location permissions are denied and app settings were not opened.');
      }

      // Recheck if location permission are granted after opening app settings
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are denied after opening app settings.');
      }
    }

    debugPrint('determinePosition ended');

    // Get the current position after granting permissions
    return await Geolocator.getCurrentPosition();
  }

  Future<void> initLocation(UserSettings settings) async {
    if (settings.city != null) return;

    try {
      final position = await determinePosition(); // If throws, jumps to catch
      final lat = settings.lat = position.latitude; // Runs if valid position
      final lng = settings.lng = position.longitude; // Runs if valid position

      // Runs only if lat & lng are set (i.e. at this point, no error is caught)
      final Geocoding geocoding = await ApiService.revGeocoding(lat, lng);
      // final city = geocoding.results.first.components.city!;
      // settings.city?.nameEn = city;
      settings.city = City(name: '', code: '', nameEn: '');
      settings.country = Country(
        isoCode: '',
        name: '',
        dialCode: '',
        nameEn: '',
        flag: '',
        cities: [],
        phoneDigitsLength: 0,
        phoneDigitsLengthMax: 0,
      );
      settings.city?.nameEn = geocoding.results.first.components.city!;
      settings.country?.nameEn = geocoding.results.first.components.country;
      // debugPrint('initLocation:: KZ_City: $city');
      debugPrint(
          'initLocation:: City: ${geocoding.results.first.components.city!}');
      debugPrint(
          'initLocation:: Country: ${geocoding.results.first.components.country}');
      debugPrint('initLocation:: '
          'Country: ${settings.country?.name} | City: ${settings.city?.name}');
      debugPrint('initLocation:: '
          'CountryEn: ${settings.country?.nameEn} | CityEn: ${settings.city?.nameEn}');

      // Assign Arabic country & city names for usage into notifications body
      settings.city?.name = settings.city!.nameEn;
      settings.country?.name = settings.country!.nameEn;
    } catch (e) {
      // Assign fallbacks for country & city in case of location error
      settings.city?.name = 'القاهرة';
      settings.country?.name = 'مصر';

      debugPrint('Error getting location: $e'); // Log the error
    }

    debugPrint('initLocation ended');
    debugPrint('initLocation:: '
        'Country: ${settings.country?.name} | City: ${settings.city?.name}');
    debugPrint('initLocation:: '
        'CountryEn: ${settings.country?.nameEn} | CityEn: ${settings.city?.nameEn}');
  }
}
