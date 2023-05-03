import 'package:flutter/material.dart';

class DropdownInputWrapped extends StatelessWidget {
  const DropdownInputWrapped({
    super.key,
    this.label,
    this.value,
    required this.choices,
    required this.setValue,
  });

  final String? value;
  final String? label;
  final List<String?> choices;
  final Function setValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label ?? ""),
        DropdownButton(
          key: ObjectKey(
              "$value-${label?.replaceAll(' ', '-').toLowerCase()}"),
          value: value ?? "",
          items: (choices)
              .map<DropdownMenuItem<String>>((String? value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value ?? ""),
            );
          }).toList(),
          onChanged: (Object? value) {
            setValue(value);
          },
        ),
      ],
    );
  }
}