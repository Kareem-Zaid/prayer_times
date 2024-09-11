import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_fut_builder.dart';
import 'package:prayer_times/screens/settings_screen.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  // String pickedCityName = 'Jazan';
  // String pickedCountryName = "Saudi Arabia";
  City? pickedCity;
  Country? pickedCountry;
  int? pickedMethod;

  void passApiArgs(City? city, Country? country, int? method) {
    setState(() {
      // city != null ? pickedCity = city : null;
      // country != null ? pickedCountry = country : null;
      // pickedCity ??= city; // <null-aware assignment operator>
      pickedCity = city;
      pickedCountry = country;
      pickedMethod = method;
    });
    debugPrint(
        'passApiArgs in HomeScreen: ${city?.name}, ${country?.name}, $method');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  passApiArgs: passApiArgs,
                  passedCity: pickedCity,
                  passedCountry: pickedCountry,
                ),
              ));
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: PrayerFutBuilder(
        city: pickedCity?.nameEn ?? 'Jazan',
        country: pickedCountry?.nameEn ?? 'Saudi Arabia',
        method: pickedMethod,
      ),
      floatingActionButton: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Positioned(
            bottom: 73,
            child: FloatingActionButton(
              heroTag: 'reset',
              mini: true,
              onPressed: () => setState(() => _counter = 0),
              tooltip: 'تصفير',
              child: const Icon(Icons.restart_alt),
            ),
          ),
          Positioned(
            height: 77,
            width: 77,
            bottom: 0,
            child: FloatingActionButton.large(
              heroTag: 'counter',
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              onPressed: () => setState(() => _counter++),
              tooltip: 'مسبحة',
              child: _counter == 0
                  ? Image.asset('assets/images/beads.png', height: 50)
                  : Text('$_counter',
                      style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
        ],
      ),
    );
  }
}
