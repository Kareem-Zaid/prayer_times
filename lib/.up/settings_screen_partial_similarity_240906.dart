import 'package:flutter/material.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

final _uniCountryServices = UniCountryServices.instance;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const String routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Country> countries = [];

  // Get the countries and cities from the package
  Future<void> _getCountriesAndCities() async {
    countries = await _uniCountryServices.getCountriesAndCities();
    countries.singleWhere((x) => x.name == ' الولايات المتحدة').name =
        'الولايات المتحدة';
    countries.singleWhere((y) => y.name == ' جزر جوادلوب').name = 'جزر جوادلوب';
    countries.singleWhere((y) => y.name == 'Kosovo').name = 'كوسوفو';
    countries.singleWhere((y) => y.name == 'کوراسائو').name = 'كوراسائو';

    setState(() {});
  }

  void sortCountries() => countries.sort((a, b) => a.name.compareTo(b.name));

  // bool isFullyMatchingWith1CharTolerance(String input, String option) {
  //   if ((input.length - option.length).abs() > 1) return false;
  //   int differences = 0;
  //   int minLength = input.length < option.length ? input.length : option.length;
  //   for (int i = 0; i < minLength; i++) {
  //     if (input[i] != option[i]) differences++;
  //     if (differences > 1) return false;
  //   }
  //   // Count extra characters in case of unequal lengths
  //   differences += (input.length - option.length).abs();
  //   return differences <= 1;
  // }

  // Function to check if a substring of the option matches the input with one character difference tolerance
  bool isSimilarWithTolerance(String input, String option) {
    if (option.contains(input)) {
      return true; // If option contains the input, it's a valid partial match
    }

    // Check for tolerance in all substrings of the option
    for (int i = 0; i <= option.length - input.length; i++) {
      String substring = option.substring(i, i + input.length);
      if (isSimilarWithToleranceBetweenStrings(input, substring)) {
        return true;
      }
    }

    return false;
  }

  // Helper function to check similarity with one character tolerance
  bool isSimilarWithToleranceBetweenStrings(String input, String substring) {
    if ((input.length - substring.length).abs() > 1) return false;

    int differences = 0;
    int minLength =
        input.length < substring.length ? input.length : substring.length;

    for (int i = 0; i < minLength; i++) {
      if (input[i] != substring[i]) {
        differences++;
      }
      if (differences > 1) return false;
    }

    // Count extra characters in case of unequal lengths
    differences += (input.length - substring.length).abs();

    return differences <= 1;
  }

  @override
  void initState() {
    super.initState();
    // Get the countries and cities on init of the view
    _getCountriesAndCities();
  }

  @override
  Widget build(BuildContext context) {
    if (countries.isNotEmpty) {
      // sortCountries();
      // countries[0].name = 'الولايات المتحدة'; // Not guaranteed enough
      // countries[1].name = 'جزر جوادلوب'; // It's better to loop for name value
      // countries.sublist(0, 3).forEach((item) => debugPrint(item.name));
      // debugPrint(countries.last.name);
      // countries.singleWhere((y) => y.name == 'کوراسائو').name = 'كوراسائو';
      sortCountries();
    }

    // for (var country in countries) {debugPrint(country.name);} [1]
    // countries.forEach((country) => debugPrint(country.name)); [1]
    // countries.map((country) => debugPrint(country.name)).toList(); [1]
    // All 3 statements do the same job [1]

// edit first 3 items of the list
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Column(
        children: [
          // const UniCountryCityPicker(),
          DropdownButton(
            hint: const Text('اختر الدولة'),
            // value: 'Icons.home',
            items: countries.map((country) {
              return DropdownMenuItem(
                value: country.name,
                child: Text(country.name),
              );
            }).toList(),
            onChanged: (value) {},
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Autocomplete(
              // initialValue: const TextEditingValue(text: 'اختر الدولة'),
              optionsBuilder: (v) {
                if (v.text.isEmpty) return const Iterable<String>.empty();

                // final List<int> options = [1, 2, 3];
                // final List<Country> matches = countries.where((x) => x.name.contains('$v')).toList();
                final List<String> matches = [];
                for (var country in countries) {
                  if (country.name.contains(v.text) ||
                      isSimilarWithTolerance(v.text, country.name)) {
                    matches.add(country.name);
                  }
                }
                debugPrint(matches.toString());
                return matches;
              },
            ),
          ),
        ],
      ),
    );
  }
}
