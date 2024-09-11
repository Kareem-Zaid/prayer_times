import 'package:flutter/material.dart';
import 'package:prayer_times/screens/picker_screen.dart';
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
  // List<City> cities = [];

  // Get the countries and cities from the package
  Future<void> _getCountriesAndCities() async {
    countries = await _uniCountryServices.getCountriesAndCities();

    fixCountryNames();
    sortCountries();
    sortCities();
    setState(() {});
  }

  void fixCountryNames() {
    _updateCountryNameAr(' الولايات المتحدة', 'الولايات المتحدة');
    _updateCountryNameAr(' جزر جوادلوب', 'جزر جوادلوب');
    _updateCountryNameAr('Kosovo', 'كوسوفو');
    _updateCountryNameAr('کوراسائو', 'كوراسائو');
    _updateCountryNameAr('اسرائیل', 'فلسطين المحتلة');
  }

  // https://chatgpt.com/c/66db19ac-c688-8007-93f4-bbe8c650e40f
  void _updateCountryNameAr(String oldName, String newName) {
    var country = countries.singleWhere((x) => x.name == oldName);
    country.name = newName;
  }

  void sortCountries() => countries.sort((a, b) => a.name.compareTo(b.name));

  void sortCities() {
    for (var country in countries) {
      country.cities.sort(
        (a, b) => a.name.compareTo(b.name),
      );
    }
  }

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

  Iterable<String> searchLogic(TextEditingValue v, List items) {
    if (v.text.isEmpty) return const Iterable<String>.empty(); // Empty Iterable
    final List<String> matches = [];
    for (var item in items) {
      if (item.name.contains(v.text) || isSimilar(v.text, item.name)) {
        matches.add(item.name);
      }
    }
    debugPrint(matches.toString());
    return matches; // List<String> can be returned as Iterable<String>
  }

  @override
  void initState() {
    super.initState();
    _getCountriesAndCities(); // Get the countries and cities on init of the view
  }

  String? pickedCountry;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: FractionalOffset.topRight,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('الدولة'),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .5,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return PickerScreen(countries: countries);
                          },
                        ).then((postPopValue) {
                          if (postPopValue != null) {
                            setState(() => pickedCountry = postPopValue);
                          }
                        });
                      },
                      child: Text(pickedCountry ?? 'اختر الدولة...'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
