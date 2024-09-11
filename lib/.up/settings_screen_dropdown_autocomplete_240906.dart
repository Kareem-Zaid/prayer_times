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

    fixCountryNames();

    sortCountries();

    setState(() {});
  }

  void fixCountryNames() {
    _updateCountryName(' الولايات المتحدة', 'الولايات المتحدة');
    _updateCountryName(' جزر جوادلوب', 'جزر جوادلوب');
    _updateCountryName('Kosovo', 'كوسوفو');
    _updateCountryName('کوراسائو', 'كوراسائو');
    _updateCountryName('اسرائیل', 'فلسطين المحتلة');
  }

  // https://chatgpt.com/c/66db19ac-c688-8007-93f4-bbe8c650e40f
  void _updateCountryName(String oldName, String newName) {
    var country = countries.singleWhere((x) => x.name == oldName);
    country.name = newName;
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

  bool isSimilar(String input, String option) {
    if (input.length > option.length) return false;
    // Input can't be longer than option

    int differences = 0;
    int matchLength = input.length;

    for (int i = 0; i < matchLength; i++) {
      if (i < option.length && input[i] != option[i]) differences++;

      if (differences > 1) return false; // Allow only one different character
    }

    return true; // Allow partial match with up to one different character
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
                      isSimilar(v.text, country.name)) {
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
