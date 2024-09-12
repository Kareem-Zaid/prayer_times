import 'package:flutter/material.dart';
import 'package:prayer_times/api_service.dart';
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
  ApiPars currentApiPars = ApiPars();

  void passApiArgs(ApiPars apiPars) {
    setState(() => currentApiPars = apiPars);
    debugPrint(
        'passApiArgs in HomeScreen: ${apiPars.city?.name}, ${apiPars.country?.name}, ${apiPars.method}');
  }

// @override
//   void didUpdateWidget(covariant HomeScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     debugPrint('Old-widget City in HomeScreen: ${oldWidget.currentApiPars.city?.name}');
//     debugPrint('Current-widget City in HomeScreen: ${currentApiPars.city?.name}');
//   }

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
                  passedApiPars: currentApiPars,
                ),
              ));
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: PrayerFutBuilder(apiPars: currentApiPars),
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
