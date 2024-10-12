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
        // MediaQuery,
        StatelessWidget,
        TextStyle,
        TextTheme,
        Theme,
        ThemeData,
        Widget,
        // debugPrint,
        runApp;
import 'package:prayer_times/screens/tabs_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prayer_times/services/local_notifs_service.dart';
// import 'package:prayer_times/screens/settings_screen.dart';

Future<void> main() async {
  // LocalNotifsService _localNotifs = LocalNotifsService();
  await LocalNotifsService().initLocalNotifs();
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
    // debugPrint('MyApp Height: ${MediaQuery.sizeOf(context).height}');
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
      // initialRoute: TabsScreen.routeName,
      home: const TabsScreen(),
      // routes: {
      // TabsScreen.routeName: (context) => const TabsScreen(),
      // SettingsScreen.routeName: (context) => const SettingsScreen(),
      // },
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
// v1.0.0: Add yearly tab and logic with page jumping {240927}
// v1.0.0: Add monthly tab and logic with scrolling to selected date {240929}
// v1.0.0: Add "Refresh" button to reload in case of error occured {241005}
// v1.0.0: Add local notifications {241007}
// v1.0.0: Set city and country with current location {241007}
// v1.1.0: Cache settings (data persistence)
// v1.2.0: Add a splash screen, then initially ask for location before proceeding to home (InitialScreen extends SettingsScreen, and pass ApiPars class to HomeScreen currentApiPars [currentApiPars = widget.initApiPars])
// v1.2.1: Add automatic refresh to next prayer every while (e.g. 30 mins, 1 min)
// v1.2.2: Try geocoding package instead of the API endpoint (Backup lib folder in ".up" before proceeding)
// v1.3.0: English localization
// v1.3.0: Enable searching in English in Arabic cities and countries names
// v1.3.1: Add skeletonizer
// v1.3.2: Code the calendar natively, without 3rd-party packages (https://chatgpt.com/c/66effbf1-9b64-8007-9a89-69fb5bfaec9d)