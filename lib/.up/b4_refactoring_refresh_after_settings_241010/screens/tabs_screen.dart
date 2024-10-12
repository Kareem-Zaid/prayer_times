import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/screens/monthly_screen.dart';
import 'package:prayer_times/screens/yearly_screen.dart';
import 'package:prayer_times/screens/daily_screen.dart';
import 'package:prayer_times/screens/settings_screen.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/services/local_notifs_service.dart';
import 'package:prayer_times/services/location_service.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  // static const String routeName = '/';

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _counter = 0;
  UserSettings currentSettings = UserSettings();
  int _selTabIndex = 0;
  final LocalNotifsService _localNotifs = LocalNotifsService();
  final LocationService _locationService = LocationService();
  bool _isLoading = true;

  void callbackApiPars(UserSettings settings) {
    setState(() => currentSettings = settings);
    debugPrint(
        'passApiArgs in HomeScreen: ${settings.country?.name}, ${settings.city?.name}, ${settings.method?.name}');
  }

  void _refreshCurrentTab() {
    setState(() {
      if (_selTabIndex == 0) {
        DailyScreenState.future = ApiService.getPrayerDay(
            date: DateTime.now(), apiPars: currentSettings);
      } else if (_selTabIndex == 1) {
        MonthlyScreenState.future = ApiService.getPrayerMonth(
            date: DateTime.now(), apiPars: currentSettings);
      } else if (_selTabIndex == 2) {
        YearlyScreenState.future = ApiService.getPrayerYear(
            date: DateTime.now(), apiPars: currentSettings);
      }
    });
  }

  void initLocationAndNotifs() async {
    try {
      await _locationService.initLocation(currentSettings);
      debugPrint(
          'currentSettings:: ${currentSettings.lat} | ${currentSettings.lng}');
    } catch (e) {
      if (mounted) {
        // Update the UI to inform the user about the error
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error getting location: $e")));
      }
    }
    setState(() => _isLoading = false);
    _localNotifs.schedulePrayerNotifications(currentSettings);
  }

  @override
  void initState() {
    super.initState();
    initLocationAndNotifs();
    debugPrint('TabScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false; // Show layout gridlines

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
        title: Text(tabs[_selTabIndex]['Title'] as String),
        actions: [
          IconButton(
            onPressed: () => _refreshCurrentTab(),
            icon: const Icon(Icons.refresh_rounded),
          ),
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
      body: _isLoading
          ? const LinearProgressIndicator()
          : IndexedStack(
              // This prevents tabs from rebuilding unnecessarily on switching
              index: _selTabIndex,
              children: tabs.map((tab) => tab['Screen'] as Widget).toList(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selTabIndex == 0
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
        currentIndex: _selTabIndex,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        selectedItemColor: Theme.of(context).colorScheme.onSurface,
        // selectedIconTheme: IconThemeData(color: Colors.amber),
        onTap: (ndx) => setState(() => _selTabIndex = ndx),
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
