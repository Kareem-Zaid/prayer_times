import 'package:flutter/material.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class PickerScreen extends StatelessWidget {
  const PickerScreen({super.key, required this.countries});

  final List<Country> countries;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر الدولة'),
      content: Column(
        children: [
          const TextField(),
          SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            width: MediaQuery.of(context).size.width * .7,
            child: ListView.builder(
              itemCount: countries.length,
              // shrinkWrap: true,
              // physics: const ClampingScrollPhysics(),
              itemBuilder: (c, i) {
                return ListTile(
                  title: Text(countries[i].name),
                  onTap: () {
                    Navigator.of(context).pop(countries[i].name);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
