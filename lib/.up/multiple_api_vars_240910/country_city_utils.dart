import 'package:flutter/foundation.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

final _uniCountryServices = UniCountryServices.instance;

class CountryCityUtils {
  static List<Country> countries = [];
  static bool initDone = false;
  // Map of old names to new names
  static final Map<String, String> nameFixes = {
    ' الولايات المتحدة': 'الولايات المتحدة',
    ' جزر جوادلوب': 'جزر جوادلوب',
    'Kosovo': 'كوسوفو',
    'کوراسائو': 'كوراسائو',
    'اسرائیل': 'فلسطين المحتلة',
  };

  // Get the countries and cities from the package
  static Future<List<Country>> initCountriesAndCities() async {
    if (!initDone) {
      countries = await _uniCountryServices.getCountriesAndCities();

      fixCountryNames();
      sortCountries();
      sortCities();

      initDone = true; // First run done flag
    }
    return countries;
  }

  static void fixCountryNames() {
    for (var entry in nameFixes.entries) {
      _fixCountryNameAr(entry.key, entry.value);
    }
  }

// https://chatgpt.com/c/66db19ac-c688-8007-93f4-bbe8c650e40f
  static void _fixCountryNameAr(String oldName, String newName) {
    try {
      var country = countries.singleWhere((x) => x.name == oldName);
      if (country.name != newName) country.name = newName;
    } catch (e) {
      debugPrint('Country with name $oldName not found: $e');
    }
  }

  static void sortCountries() =>
      countries.sort((a, b) => a.name.compareTo(b.name));

  static void sortCities() {
    for (var country in countries) {
      country.cities.sort((a, b) => a.name.compareTo(b.name));
    }
  }
}
