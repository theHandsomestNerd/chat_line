import 'package:flutter/material.dart';

class DateInputWrapped extends StatelessWidget {
  const DateInputWrapped({
    super.key,
    required this.value,
    required this.setValue,
    this.label
  });

  final DateTime? value;
  final Function setValue;
  final String? label;

  @override
  Widget build(BuildContext context) {
    Future<void> selectDate(
        BuildContext context, DateTime? theDate, Function updateDate) async {
      DateTime? picked = await showDatePicker(
          context: context,
          initialDate: theDate ?? DateTime(2023),
          firstDate: DateTime(1950),
          lastDate: DateTime(2100));
      if (picked != null && picked != theDate) {
        updateDate(picked);
      }
    }

    return ListTile(
      title: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            value == null
                ? const Text('no date selected')
                : Text("${value?.toLocal()}".split(' ')[0]),
            const SizedBox(
              width: 20.0,
            ),
            ElevatedButton(
              onPressed: () => selectDate(context, value, setValue),
              child: Text('Select $label'),
            ),
          ],
        ),
      ),
    );
  }
}