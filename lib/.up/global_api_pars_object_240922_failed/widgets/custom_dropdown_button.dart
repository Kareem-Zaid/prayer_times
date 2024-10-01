import 'package:flutter/material.dart';
import 'package:prayer_times/models/api_pars.dart';

class CustomDropdownButton extends StatelessWidget {
  const CustomDropdownButton({
    super.key,
    required this.methodList,
    required this.buttonValue,
    required this.onChanged,
  });
  final List<Method> methodList;
  final Method? buttonValue;
  final void Function(Method?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: const Text('طريقة \n الحساب', textAlign: TextAlign.center),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width * .66,
          child: DropdownButton(
            padding: const EdgeInsets.all(8.0),
            borderRadius: BorderRadius.circular(8.000),
            isExpanded: true, // Pivotal
            hint: const Center(child: Text('اختر طريقة الحساب...')),
            value: buttonValue,
            items: [
              DropdownMenuItem<Method>(
                  value: const Method(index: -1, name: 'الافتراضي'),
                  child: Center(
                      child: Text(
                    'الافتراضي',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ))),
              ...methodList.map((methodItem) {
                return DropdownMenuItem(
                    value: methodItem,
                    child: Center(
                        child: Text(
                      methodItem.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge,
                    )));
              }) /* .toList() */
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
