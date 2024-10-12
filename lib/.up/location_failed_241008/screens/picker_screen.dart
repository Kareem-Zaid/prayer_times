import 'package:flutter/material.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key, required this.items, required this.iLabel});
  final List items;
  final String iLabel;

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  List filteredItems = [];

  bool isSimilar(String input, String option) {
    if (input.length > option.length) return false;
    // Input can't be longer than option

    int differences = 0;
    int matchLength = input.length;

    for (int i = 0; i < matchLength; i++) {
      if (i < option.length && input[i] != option[i]) differences++;

      if (differences > 1) return false; // Allow only one different character
    }

    return true; // Allow partial match with up to one different character
  }

  List searchLogic(String input, List items) {
    if (input.isEmpty) return items;
    final List matches = [];
    for (var item in items) {
      if (item.name.contains(input) || isSimilar(input, item.name)) {
        matches.add(item);
      }
    }
    // debugPrint(matches.toString());
    return matches;
  }

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('اختر ${widget.iLabel}')),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * .7,
        width: MediaQuery.of(context).size.width * .7,
        child: Column(
          children: [
            TextField(
              decoration:
                  InputDecoration(labelText: 'أدخل اسم ${widget.iLabel}'),
              onChanged: (v) {
                setState(() => filteredItems = searchLogic(v, widget.items));
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                // shrinkWrap: true,
                // physics: const ClampingScrollPhysics(),
                itemBuilder: (c, i) {
                  return ListTile(
                    title: Text(filteredItems[i].name),
                    onTap: () => Navigator.of(context).pop(filteredItems[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
