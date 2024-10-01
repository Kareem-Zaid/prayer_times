import 'package:flutter/material.dart';
import 'package:prayer_times/models/api_pars.dart';
import 'package:prayer_times/services/country_city_service.dart';
// import 'package:prayer_times/screens/picker_screen.dart';
import 'package:prayer_times/widgets/custom_dropdown_button.dart';
import 'package:prayer_times/widgets/custom_picker_button.dart';
import 'package:prayer_times/widgets/custom_switch.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.callbackApiArgs,
    required this.passedApiPars,
  });
  // static const String routeName = '/settings';
  final void Function(ApiPars apiPars) callbackApiArgs;
  final ApiPars passedApiPars;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Country> countries = [];
  bool isLoading = false;

  void setCountries() async {
    setState(() => isLoading = true);
    countries = await CountryCityUtils.initCountriesAndCities();
    setState(() => isLoading = false);
  }

  List<Method> methodList = [];
  void getMethods() {
    methodList = Method.methods.entries
        .map((x) => Method(index: x.key, name: x.value))
        .toList();
  }

  late ApiPars pickedApiPars;
  String countryLabel = 'الدولة';
  String cityLabel = 'المدينة';
  // bool is24H = false;

  @override
  void initState() {
    super.initState();
    setCountries();
    getMethods();
    pickedApiPars = widget.passedApiPars;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (pickedApiPars.city == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('قم باختيار الدولة والمدينة أولا')),
          );
        } else {
          debugPrint('Picked city just b4 pop: ${pickedApiPars.city?.nameEn}');
          widget.callbackApiArgs(pickedApiPars);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: isLoading
            ? const LinearProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomPickerButton(
                    iText: countryLabel,
                    items: countries,
                    pickedItem: pickedApiPars.country,
                    onItemSelected: (selectedCountry) => setState(() {
                      pickedApiPars.country = selectedCountry as Country;
                      pickedApiPars.city = null; // Reset city on country change
                    }),
                  ),
                  CustomPickerButton(
                    iText: cityLabel,
                    items: pickedApiPars.country?.cities ?? [],
                    pickedItem: pickedApiPars.city,
                    isXPicked: pickedApiPars.country != null,
                    onItemSelected: (selectedCity) {
                      setState(() => pickedApiPars.city = selectedCity as City);
                    },
                  ),
                  CustomDropdownButton(
                    methodList: methodList,
                    buttonValue: pickedApiPars.method,
                    onChanged: (newMethod) {
                      // newMethod as Method;
                      debugPrint('Picked method: ${newMethod?.name}');
                      setState(() => pickedApiPars.method = newMethod);
                    },
                  ),
                  CustomSwitch(
                    is24H: pickedApiPars.is24H,
                    onChanged: (isOn) {
                      setState(() => pickedApiPars.is24H = isOn);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
