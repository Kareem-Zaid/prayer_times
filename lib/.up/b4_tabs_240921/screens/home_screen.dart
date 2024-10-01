import 'package:flutter/material.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/widgets/prayer_fut_builder.dart';
import 'package:prayer_times/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  ApiPars currentApiPars = ApiPars();

  void callbackApiPars(ApiPars apiPars) {
    setState(() => currentApiPars = apiPars);
    debugPrint(
        'passApiArgs in HomeScreen: ${apiPars.country?.name}, ${apiPars.city?.name}, ${apiPars.method?.name}');
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
                  callbackApiArgs: callbackApiPars,
                  passedApiPars: currentApiPars,
                ),
              ));
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: PrayerFutBuilder(
        apiPars: ApiPars(
          country: currentApiPars.country,
          city: currentApiPars.city,
          method: currentApiPars.method,
          is24H: currentApiPars.is24H,
        ),
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
                  : Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.abc), label: '7amada'),
        BottomNavigationBarItem(icon: Icon(Icons.kayaking), label: 'mesa'),
        BottomNavigationBarItem(icon: Icon(Icons.no_accounts), label: 'saba7o'),
      ]),
    );
  }
}
