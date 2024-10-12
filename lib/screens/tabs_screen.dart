import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/screens/monthly_screen.dart';
import 'package:prayer_times/screens/yearly_screen.dart';
import 'package:prayer_times/screens/daily_screen.dart';
import 'package:prayer_times/screens/settings_screen.dart';
import 'package:prayer_times/services/local_notifs_service.dart';
import 'package:prayer_times/services/location_service.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with WidgetsBindingObserver {
  int _counter = 0;
  late UserSettings currentSettings;
  List<Map<String, Object>> tabs = [];
  int _selTabIndex = 0;
  final LocalNotifsService _localNotifs = LocalNotifsService();
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  late bool _locationEnabled;

  Future<void> initLocationAndNotifs() async {
    if (currentSettings.lat == null || currentSettings.lng == null) {
      try {
        await _locationService.initLocation(currentSettings);
      } catch (e) {
        if (mounted) {
          // Update the UI to inform the user about the error
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error getting location: $e")));
        }
      }
      _locationEnabled = await Geolocator.isLocationServiceEnabled();
      if (_locationEnabled) {
        await _localNotifs.cancelAllNotifications();
        _localNotifs.schedulePrayerNotifications(currentSettings);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshCurrentTab() async {
    await initLocationAndNotifs();
    setState(() {
      if (_selTabIndex == 0) {
        DailyScreenState.assignPrayerDay(currentSettings);
      } else if (_selTabIndex == 1) {
        MonthlyScreenState.assignPrayerMonth(currentSettings);
      } else if (_selTabIndex == 2) {
        YearlyScreenState.assignPrayerYear(currentSettings);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        !currentSettings.isLocationHandled) {
      // First run done flag
      currentSettings.isLocationHandled = true;

      await initLocationAndNotifs();

      _locationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationEnabled && currentSettings.lat == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('جاري عرض مواقيت الصلاة طبقا للموقع الافتراضي: '
              '${currentSettings.cityName} - ${currentSettings.countryName}'),
        ));
        _localNotifs.schedulePrayerNotifications(currentSettings);
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    currentSettings = UserSettings(context: context);
    WidgetsBinding.instance.addObserver(this);
    initLocationAndNotifs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('passApiArgs in HomeScreen: ${currentSettings.country?.name}, '
        '${currentSettings.city?.name}, ${currentSettings.method?.name}');
    tabs = [
      {
        'Screen': DailyScreen(settings: currentSettings),
        'Title': 'مواقيت الصلاة',
      },
      {
        'Screen': MonthlyScreen(settings: currentSettings),
        'Title': 'مواقيت الصلاة خلال الشهر'
      },
      {
        'Screen': YearlyScreen(settings: currentSettings),
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
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) =>
                          SettingsScreen(passedSettings: currentSettings)))
                  .then((_) => setState(() {}));
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const LinearProgressIndicator()
          : IndexedStack(
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
