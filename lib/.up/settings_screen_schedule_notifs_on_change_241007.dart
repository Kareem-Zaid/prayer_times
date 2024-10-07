import 'package:flutter/material.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/services/country_city_service.dart';
import 'package:prayer_times/services/local_notifs_service.dart';
import 'package:prayer_times/utils/string_extensions.dart';
import 'package:prayer_times/widgets/custom_dropdown_button.dart';
import 'package:prayer_times/widgets/custom_picker_button.dart';
import 'package:prayer_times/widgets/custom_switch.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

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
  bool _didCityChange = false;
  bool _didMethodChange = false;
  late UserSettings pickedSettings;
  final LocalNotifsService _localNotifs = LocalNotifsService();
  static const String countryLabel = 'الدولة';
  static const String cityLabel = 'المدينة';

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
          debugPrint(pickedSettings.city?.nameEn);
          debugPrint(widget.passedSettings.city?.nameEn);
          if (pickedSettings.city?.nameEn !=
              widget.passedSettings.city?.nameEn) {
            debugPrint('Settings changed');
            _localNotifs.schedulePrayerNotifications(pickedSettings);
          }
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
                    onItemSelected: (selectedCountry) {
                      setState(() {
                        pickedSettings.country = selectedCountry as Country;
                        // Reset city on country change
                        pickedSettings.city = null;
                      });
                    },
                  ),
                  CustomPickerButton(
                    iText: cityLabel,
                    items: pickedSettings.country?.cities ?? [],
                    pickedItem: pickedSettings.city,
                    isXPicked: pickedSettings.country != null,
                    onItemSelected: (selectedCity) {
                      if (selectedCity != pickedSettings.city) {
                        // bool didCityChange
                        debugPrint('City changed');
                        setState(() {
                          pickedSettings.city = selectedCity as City;
                        });
                      }
                    },
                  ),
                  CustomDropdownButton(
                    methodList: Method.methodList,
                    buttonValue: pickedSettings.method,
                    onChanged: (newMethod) {
                      // newMethod as Method;
                      if (newMethod != pickedSettings.method) {
                        debugPrint('Method changed');
                        setState(() => pickedSettings.method = newMethod);
                      }
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
                      if (!pickedSettings.isNotifsOn) {
                        await _localNotifs.cancelAllNotifications();
                        debugPrint('Notifications canceled');
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
