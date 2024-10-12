import 'package:flutter/foundation.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

final _uniCountryServices = UniCountryServices.instance;

class CountryCityService {
  static List<Country> _countries = [];
  static bool _initDone = false;
  // Map of old names to new names
  static final Map<String, String> _nameFixes = {
    ' الولايات المتحدة': 'الولايات المتحدة',
    ' جزر جوادلوب': 'جزر جوادلوب',
    'Kosovo': 'كوسوفو',
    'کوراسائو': 'كوراسائو',
    'اسرائیل': 'فلسطين المحتلة',
  };

  // Get the countries and cities from the package
  static Future<List<Country>> initCountriesAndCities() async {
    if (!_initDone) {
      _countries = await _uniCountryServices.getCountriesAndCities();

      _fixCountryNames();
      _sortCountries();
      _sortCities();

      _initDone = true; // First run done flag
    }
    return _countries;
  }

// https://chatgpt.com/c/66db19ac-c688-8007-93f4-bbe8c650e40f
  static void _fixCountryNames() {
    for (var entry in _nameFixes.entries) {
      try {
        var country = CountryCityService._countries
            .singleWhere((x) => x.name == entry.key);
        if (country.name != entry.value) country.name = entry.value;
      } catch (e) {
        debugPrint('Country with name ${entry.key} not found: $e');
      }
    }
  }

  static void _sortCountries() =>
      _countries.sort((a, b) => a.name.compareTo(b.name));

  static void _sortCities() {
    for (var country in _countries) {
      country.cities.sort((a, b) => a.name.compareTo(b.name));
    }
  }
}
