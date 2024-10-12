import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times/models/geocoding.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/services/api_service.dart';

class LocationService {
  bool get serviceEnabled {
    bool isEnabled = false;
    Geolocator.isLocationServiceEnabled().then((v) => isEnabled = v);
    return isEnabled;
  }

  Future<Position> determinePosition() async {
    debugPrint('determinePosition started');
    // bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    if (!serviceEnabled) {
      // Prompt the user to enable location services
      bool openedSettings = await Geolocator.openLocationSettings();
      if (!openedSettings) {
        return Future.error(
            'Location services are disabled and settings were not opened.');
      }

      // Recheck if location services are enabled after opening settings
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

      settings.cityName = geocoding.results.first.components.city!;
      settings.countryName = geocoding.results.first.components.country;

      debugPrint('initLocation:: '
          'Country: ${settings.countryName} | City: ${settings.cityName}');
    } catch (e) {
      // Assign fallbacks for country & city in case of location error
      settings.cityName = 'القاهرة';
      settings.countryName = 'مصر';

      debugPrint('Error getting location: $e'); // Log the error
    }
    debugPrint('initLocation ended');
  }
}
