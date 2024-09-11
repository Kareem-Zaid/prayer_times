import 'package:uni_country_city_picker/uni_country_city_picker.dart';

final _uniCountryServices = UniCountryServices.instance;

class CountryCityUtils {
  static List<Country> countries = [];
  static bool namesFixed = false;

  // Get the countries and cities from the package
  static Future<List<Country>> getCountriesAndCities() async {
    if (!namesFixed) {
      countries = await _uniCountryServices.getCountriesAndCities();

      fixCountryNames();
      sortCountries();
      sortCities();

      namesFixed = true;
    }
    return countries;
  }

  static void fixCountryNames() {
    _fixCountryNameAr(' الولايات المتحدة', 'الولايات المتحدة');
    _fixCountryNameAr(' جزر جوادلوب', 'جزر جوادلوب');
    _fixCountryNameAr('Kosovo', 'كوسوفو');
    _fixCountryNameAr('کوراسائو', 'كوراسائو');
    _fixCountryNameAr('اسرائیل', 'فلسطين المحتلة');
  }

// https://chatgpt.com/c/66db19ac-c688-8007-93f4-bbe8c650e40f
  static void _fixCountryNameAr(String oldName, String newName) {
    var country = countries.singleWhere((x) => x.name == oldName);
    if (country.name != newName) country.name = newName;
  }

  static void sortCountries() =>
      countries.sort((a, b) => a.name.compareTo(b.name));

  static void sortCities() {
    for (var country in countries) {
      country.cities.sort((a, b) => a.name.compareTo(b.name));
    }
  }
}
