import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:prayer_times/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prayer_times/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: const Locale('ar'),
      debugShowCheckedModeBanner: false,
      title: 'Prayer Times',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme:
            AppBarTheme(color: Theme.of(context).colorScheme.inversePrimary),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 17.0),
          labelSmall: TextStyle(fontSize: 17),
        ),
      ),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
      },
    );
  }
}

// v1.0.0: Mesba7a; with reset feature, and related icon | Date only, without time {240828}
// v1.0.0: DatePicker and assigning arguments to variables {240829}
// v1.0.0: Next Prayer Widget (no null | widget doesn't update until hot reload | should be called at the beginng?) | after hh mm
// v1.0.0: Add city, country, and method in settings, and add their pickers
// v1.0.0: Add Time Format (24h/12h) in settings
// v1.0.0: Add monthly and yearly tabs
// v1.0.0: Add local notifications
// v1.1.0: Try geocoding package instead of the API endpoint (Copy files in ".up" before proceeding)
// v1.1.0: English localization