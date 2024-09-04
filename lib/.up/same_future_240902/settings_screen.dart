import 'package:flutter/material.dart';
// import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: const Center(child: Text('الإعدادات')),
    );
  }
}
