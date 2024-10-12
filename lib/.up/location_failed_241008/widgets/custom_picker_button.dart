import 'package:flutter/material.dart';
import 'package:prayer_times/screens/picker_screen.dart';

class CustomPickerButton extends StatelessWidget {
  const CustomPickerButton({
    super.key,
    required this.iText,
    required this.items,
    required this.pickedItem,
    this.isXPicked = true,
    required this.onItemSelected,
  });
  final String iText;
  final List<Object> items;
  final dynamic pickedItem;
  final bool isXPicked;
  final void Function(Object?) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Text(iText),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width * .65,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () async {
              if (isXPicked) {
                final postPopValue = await showDialog(
                  context: context,
                  builder: (c) => PickerScreen(items: items, iLabel: iText),
                );
                if (postPopValue != null) {
                  // Update picked item after selection and popping
                  onItemSelected(postPopValue);
                  debugPrint('Picked item after pop: ${postPopValue.name}');
                }
              }
            },
            label: Text(pickedItem?.name ?? // [3]
                (isXPicked
                    ? 'اختر $iText...' // [1]
                    : 'اختر الدولة أولا...')),
          ),
        ),
      ),
    );
  }
}
