import 'dart:ui';
import 'package:flutter/material.dart'
    show
        AppBarTheme,
        BuildContext,
        ColorScheme,
        Colors,
        Locale,
        MaterialApp,
        MaterialScrollBehavior,
        StatelessWidget,
        TextStyle,
        TextTheme,
        Theme,
        ThemeData,
        Widget,
        runApp;
import 'package:flutter/rendering.dart';
import 'package:prayer_times/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:prayer_times/screens/settings_screen.dart';

void main() {
  debugPaintSizeEnabled = false; // Show layout gridlines
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
        // SettingsScreen.routeName: (context) => const SettingsScreen(),
      },
    );
  }
}

// v1.0.0: Mesba7a; with reset feature, and related icon | Date only, without time {240828}
// v1.0.0: DatePicker and assigning arguments to variables {240829}
// v1.0.0: Next Prayer Widget | after hh mm {240903}
// v1.0.0: Add city and country pickers/UI & parameters/logic in settings {240910} (Reduce variables if possible)
// v1.0.0: Do some encapsulation and abstaction {240911}
// v1.0.0: Add calculation method class in api_serivce.dart, and picker & parameters in settings {240912}
// v1.0.0: Add Time Format (24h/12h) in settings {240921}
// v1.0.0: Add monthly and yearly tabs
// v1.0.0: Add local notifications
// v1.1.0: Try geocoding package instead of the API endpoint (Copy files in a folder in ".up" before proceeding)
// v1.1.0: Add automatic refresh to next prayer every while (e.g. 30 mins, 1 min)
// v1.1.0: English localization
// v1.1.0: Enable searching in English in Arabic cities and countries names
// v1.1.0: Add a splash screen, then ask for location before proceeding to home (InitialScreen extends SettingsScreen, and pass ApiPars class to HomeScreen currentApiPars [currentApiPars = widget.initApiPars])