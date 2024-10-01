import 'package:flutter/material.dart';
import 'package:prayer_times/utils/string_extensions.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({super.key, required this.is24H, required this.onChanged});
  final bool is24H;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        // isThreeLine: true,
        title: Text(
          'تنسيق 24 ساعة'.toArNums(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          'صيغة الوقت الحالية: ${is24H ? '24' : '12'} ساعة'.toArNums(),
        ),
        trailing: Switch(value: is24H, onChanged: onChanged),
      ),
    );
  }
}
