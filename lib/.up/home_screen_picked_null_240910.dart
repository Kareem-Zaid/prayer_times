import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_fut_builder.dart';
import 'package:prayer_times/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  String pickedCityName = 'Jazan';
  String pickedCountryName = "Saudi Arabia";
  int? pickedMethod;
  void passPrayerArgs(String? cityName, String? countryName, int? method) {
    setState(() {
      cityName != null ? pickedCityName = cityName : null;
      countryName != null ? pickedCountryName = countryName : null;
      pickedMethod = method;
    });
    debugPrint(
        'passPrayerArgs in HomeScreen: $cityName, $countryName, $method');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          IconButton(
            onPressed: () /* async */ {
              /* await */ Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return SettingsScreen(passPrayerArgs: passPrayerArgs);
                },
              ));
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: PrayerFutBuilder(
        city: pickedCityName,
        country: pickedCountryName,
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
