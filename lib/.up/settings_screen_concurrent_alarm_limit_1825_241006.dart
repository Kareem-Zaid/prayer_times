import 'package:flutter/material.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/services/country_city_service.dart';
import 'package:prayer_times/services/local_notifs_service.dart';
import 'package:prayer_times/utils/string_extensions.dart';
// import 'package:prayer_times/screens/picker_screen.dart';
import 'package:prayer_times/widgets/custom_dropdown_button.dart';
import 'package:prayer_times/widgets/custom_picker_button.dart';
import 'package:prayer_times/widgets/custom_switch.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

LocalNotifsService _localNotifs = LocalNotifsService();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.callbackSettings,
    required this.passedSettings,
  });
  // static const String routeName = '/settings';
  final void Function(UserSettings apiPars) callbackSettings;
  final UserSettings passedSettings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Country> countries = [];
  bool _loading = false;
  late UserSettings pickedSettings;
  static const String countryLabel = 'الدولة';
  static const String cityLabel = 'المدينة';

  Future<void> _schedulePrayerNotifications() async {
    List<Future<void>> futures = [];
    // Assign API request response transformed into PrayerYear model
    PrayerYear prayerYear = await ApiService.getPrayerYear(
        date: DateTime.now(), apiPars: pickedSettings);
    // Get prayers data of a year
    Map<String, List<Datum>> yearData = prayerYear.yearData;
    // Loop months in data of a year (12)
    for (var monthStr in yearData.keys) {
      // Loop data of a day in data of a year using each month as a key (30/31)
      for (var dayData in yearData[monthStr]!) {
        // Loop prayers in prayer list property of data of each day (5)
        final prayerList = dayData.prayers.prayerList..removeAt(1);
        for (var prayer in prayerList) {
          // Schedule a notification for each prayer in a day in a year (365*5)
          futures.add(_localNotifs.zonedScheduleNotification(prayer.time));
        }
      }
    }
    // Await once, instead of awaiting 1825 times (365*5)
    await Future.wait(futures);
    debugPrint('# of scheduled notifications: ${_localNotifs.id}');
  }

  void setCountries() async {
    setState(() => _loading = true);
    countries = await CountryCityService.initCountriesAndCities();
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    setCountries();
    pickedSettings = widget.passedSettings;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (pickedSettings.city == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('قم باختيار الدولة والمدينة أولا')),
          );
        } else {
          widget.callbackSettings(pickedSettings);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: _loading
            ? const LinearProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomPickerButton(
                    iText: countryLabel,
                    items: countries,
                    pickedItem: pickedSettings.country,
                    onItemSelected: (selectedCountry) => setState(() {
                      pickedSettings.country = selectedCountry as Country;
                      pickedSettings.city =
                          null; // Reset city on country change
                    }),
                  ),
                  CustomPickerButton(
                    iText: cityLabel,
                    items: pickedSettings.country?.cities ?? [],
                    pickedItem: pickedSettings.city,
                    isXPicked: pickedSettings.country != null,
                    onItemSelected: (selectedCity) {
                      setState(
                          () => pickedSettings.city = selectedCity as City);
                    },
                  ),
                  CustomDropdownButton(
                    methodList: Method.methodList,
                    buttonValue: pickedSettings.method,
                    onChanged: (newMethod) {
                      // newMethod as Method;
                      setState(() => pickedSettings.method = newMethod);
                    },
                  ),
                  CustomSwitch(
                    value: pickedSettings.is24H,
                    onChanged: (isOn) {
                      setState(() => pickedSettings.is24H = isOn);
                    },
                    title: 'تنسيق 24 ساعة'.toArNums(),
                    subtitle:
                        'صيغة الوقت الحالية: ${pickedSettings.is24H ? '24' : '12'} ساعة'
                            .toArNums(),
                  ),
                  CustomSwitch(
                    value: pickedSettings.isNotifsOn,
                    onChanged: (isOn) async {
                      setState(() => pickedSettings.isNotifsOn = isOn);
                      if (pickedSettings.isNotifsOn) {
                        _localNotifs.requestPermissions();

                        await _schedulePrayerNotifications();
                      } else {
                        await _localNotifs.cancelAllNotifications();
                      }
                    },
                    title: 'تفعيل الإشعارات',
                    subtitle: 'إرسال إشعار تنبيهي عند كل صلاة',
                  ),
                ],
              ),
      ),
    );
  }
}
