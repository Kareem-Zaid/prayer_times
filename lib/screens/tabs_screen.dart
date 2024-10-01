import 'package:flutter/material.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/screens/monthly_screen.dart';
import 'package:prayer_times/screens/yearly_screen.dart';
import 'package:prayer_times/screens/daily_screen.dart';
import 'package:prayer_times/screens/settings_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  // static const String routeName = '/';

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _counter = 0;
  UserSettings currentSettings = UserSettings();
  int _tabIndex = 1;

  void callbackApiPars(UserSettings settings) {
    setState(() => currentSettings = settings);
    debugPrint(
        'passApiArgs in HomeScreen: ${settings.country?.name}, ${settings.city?.name}, ${settings.method?.name}');
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('TabsSc Height: ${MediaQuery.sizeOf(context).height}');
    // debugPrint('TabsSc Width: ${MediaQuery.sizeOf(context).width}');
    List<Map<String, Object>> tabs = [
      {
        'Screen': DailyScreen(
          settings: UserSettings(
            country: currentSettings.country,
            city: currentSettings.city,
            method: currentSettings.method,
            is24H: currentSettings.is24H,
          ),
        ),
        'Title': 'مواقيت الصلاة',
      },
      {
        'Screen': MonthlyScreen(
          settings: UserSettings(
            country: currentSettings.country,
            city: currentSettings.city,
            method: currentSettings.method,
            is24H: currentSettings.is24H,
          ),
        ),
        'Title': 'مواقيت الصلاة خلال الشهر'
      },
      {
        'Screen': YearlyScreen(
          settings: UserSettings(
            country: currentSettings.country,
            city: currentSettings.city,
            method: currentSettings.method,
            is24H: currentSettings.is24H,
          ),
        ),
        'Title': 'مواقيت الصلاة خلال العام'
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[_tabIndex]['Title'] as String),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  callbackSettings: callbackApiPars,
                  passedSettings: currentSettings,
                ),
              ));
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: IndexedStack(
        // This enables the widget to keep the state of the inactive tabs intact while only switching the visible tab, which prevents 'DailyScreen' from rebuilding unnecessarily.
        index: _tabIndex,
        children: tabs.map((tab) => tab['Screen'] as Widget).toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _tabIndex == 0
          ? Stack(
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
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
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
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        selectedItemColor: Theme.of(context).colorScheme.onSurface,
        // selectedIconTheme: IconThemeData(color: Colors.amber),
        onTap: (ndx) => setState(() => _tabIndex = ndx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'يومي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'شهري',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_month),
            label: 'سنوي',
          ),
        ],
      ),
    );
  }
}
