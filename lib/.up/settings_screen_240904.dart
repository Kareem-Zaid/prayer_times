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
  @override
  void initState() {
    super.initState();
    // Get the countries and cities on init of the view
    _getCountriesAndCities();
  }

  // Get the countries and cities from the package
  Future _getCountriesAndCities() async {
    countries = await _uniCountryServices.getCountriesAndCities();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    for (var country in countries) {
      debugPrint(country.name);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Column(
        children: [
          // const UniCountryCityPicker(),
          DropdownButton(
            hint: const Text('Choose Country'),
            // value: 'Icons.home',
            items: const [
              DropdownMenuItem(value: 'Icons.home', child: Icon(Icons.home)),
              DropdownMenuItem(value: 'text', child: Text('text')),
            ],
            onChanged: (value) {},
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Autocomplete(
              optionsBuilder: (v) {
                final List<String> options = [];
                return options;
              },
            ),
          ),
        ],
      ),
    );
  }
}
