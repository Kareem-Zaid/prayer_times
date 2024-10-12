import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times/models/user_settings.dart';

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
      final Position position = await determinePosition();
      settings.lat = position.latitude;
      settings.lng = position.longitude;
    } catch (e) {
      debugPrint('Error getting location: $e'); // Log the error
    }
    debugPrint('currentSettings.lat: ${settings.lat}');
    debugPrint('currentSettings.lng: ${settings.lng}');
  }
}
