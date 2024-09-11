import 'package:flutter/material.dart';
import 'package:prayer_times/country_city_utils.dart';
import 'package:prayer_times/screens/picker_screen.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.passApiArgs,
    required this.passedCity,
    required this.passedCountry,
  });
  static const String routeName = '/settings';
  // final void Function(String, String, int?) passPrayerArgs;
  final void Function(City? city, Country? country, int? method) passApiArgs;
  final City? passedCity;
  final Country? passedCountry;
  // final int? passedMethod;

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

  Country? pickedCountry;
  City? pickedCity;
  int? pickedMethod;
  String countryLabel = 'الدولة';
  String cityLabel = 'المدينة';

  @override
  void initState() {
    super.initState();
    setCountries();
    pickedCity ??= widget.passedCity;
    pickedCountry ??= widget.passedCountry;
    // pickedMethod = widget.passedMethod;
    // widget.passPrayerArgs(pickedCity?.name, pickedCountry?.nameEn, pickedMethod);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // debugPrint('picked city b4 pop: ${pickedCity?.name}');
        if (didPop) return;
        widget.passApiArgs(pickedCity, pickedCountry, pickedMethod);
        debugPrint('Settings picked city on pop: ${pickedCity?.nameEn}');
        debugPrint('~ picked country ~: ${pickedCountry?.nameEn}');
        // debugPrint('picked method: $pickedMethod');
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: isLoading
            ? const LinearProgressIndicator()
            : Column(
                children: [
                  buildPickerButton(
                    label: countryLabel,
                    pickedItem: pickedCountry,
                    items: countries,
                    onItemSelected: (selectedCountry) {
                      pickedCountry = selectedCountry as Country;
                      pickedCity = null; // Reset city when country changes
                    },
                  ),
                  buildPickerButton(
                    label: cityLabel,
                    pickedItem: pickedCity,
                    items: pickedCountry?.cities ?? [],
                    isXPicked: pickedCountry != null,
                    onItemSelected: (selectedCity) {
                      pickedCity = selectedCity as City;
                    },
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
    );
  }

  Padding buildPickerButton({
    required String label, // [1]
    // Fun fact: In this snippet, there are 3 objects named 'label': this argument [1], another argument passed to 'PickerScreen' [2], and the parameter of 'ElevatedButton.icon' widget [3]
    required var pickedItem,
    required List items,
    bool isXPicked = true,
    required Function(Object) onItemSelected, // Function to update the state
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(label), // [1]
          SizedBox(
            width: MediaQuery.of(context).size.width * .5,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () {
                if (isXPicked) {
                  showDialog(
                    context: context,
                    builder: (c) => PickerScreen(
                      items: items,
                      /* [1] */ label: label, /* [2] */
                    ),
                  ).then((postPopValue) {
                    if (postPopValue != null) {
                      // Update picked item after selection and popping
                      setState(() => onItemSelected(postPopValue));
                      debugPrint('picked item: ${pickedItem?.name}');
                    }
                  });
                }
              },
              label: Text(pickedItem?.name ?? // [3]
                  (isXPicked
                      ? 'اختر $label...' // [1]
                      : 'اختر الدولة أولا...')),
            ),
          ),
        ],
      ),
    );
  }
}
