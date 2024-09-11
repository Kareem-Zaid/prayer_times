import 'package:flutter/material.dart';
import 'package:prayer_times/country_city_utils.dart';
import 'package:prayer_times/screens/picker_screen.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.passPrayerArgs});
  static const String routeName = '/settings';
  // final void Function(String, String, int?) passPrayerArgs;
  final void Function(String? city, String? country, int? method)
      passPrayerArgs;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Country> countries = [];
  bool isLoading = false;

  void setCountries() async {
    setState(() => isLoading = true);
    countries = await CountryCityUtils.initCountriesAndCities();
    // setState(() {});
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    setCountries();
    // widget.passPrayerArgs(pickedCity?.name, pickedCountry?.nameEn, pickedMethod);
  }

  Country? pickedCountry;
  City? pickedCity;
  int? pickedMethod;
  String countryStr = 'الدولة';
  String cityStr = 'المدينة';
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // debugPrint('picked city b4 pop: ${pickedCity?.name}');
        if (didPop) return;
        widget.passPrayerArgs(
            pickedCity?.name, pickedCountry?.nameEn, pickedMethod);
        debugPrint('Settings picked city on pop: ${pickedCity?.name}');
        debugPrint('~ picked country ~: ${pickedCountry?.nameEn}');
        // debugPrint('picked method: $pickedMethod');
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: isLoading
            ? const LinearProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: FractionalOffset.topRight,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(countryStr),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .5,
                              child: ElevatedButton(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => PickerScreen(
                                      items: countries, label: countryStr),
                                ).then((postPopValue) {
                                  if (postPopValue != null) {
                                    setState(
                                        () => pickedCountry = postPopValue);
                                  }
                                }),
                                child: Text(pickedCountry?.name ??
                                    'اختر $countryStr...'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(cityStr),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .5,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (pickedCountry == null) return;
                                  showDialog(
                                    context: context,
                                    builder: (context) => PickerScreen(
                                      items: pickedCountry!.cities,
                                      label: cityStr,
                                    ),
                                  ).then((postPopValue) {
                                    if (postPopValue != null) {
                                      setState(() => pickedCity = postPopValue);
                                    }
                                  });
                                },
                                child: Text(
                                  pickedCity?.name ??
                                      (pickedCountry == null
                                          ? 'اختر $countryStr أولا...'
                                          : 'اختر $cityStr...'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text('طريقة \n الحساب',
                                textAlign: TextAlign.center),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .5,
                              child: DropdownButton(
                                items: const [],
                                onChanged: (value) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
