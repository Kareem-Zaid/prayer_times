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

// https://chatgpt.com/c/66db19ac-c688-8007-93f4-bbe8c650e40f
  static void fixCountryNames() {
    for (var entry in nameFixes.entries) {
      try {
        var country =
            CountryCityUtils.countries.singleWhere((x) => x.name == entry.key);
        if (country.name != entry.value) country.name = entry.value;
      } catch (e) {
        debugPrint('Country with name ${entry.key} not found: $e');
      }
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
