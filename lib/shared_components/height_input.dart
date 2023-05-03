import 'package:cookowt/wrappers/text_field_wrapped.dart';
import 'package:flutter/material.dart';

import '../models/submodels/height.dart';

class HeightInput extends StatefulWidget {
  const HeightInput({super.key, required this.updateHeight, this.initialValue});

  final Function updateHeight;
  final Height? initialValue;

  @override
  State<HeightInput> createState() => _HeightInputState();
}

class _HeightInputState extends State<HeightInput> {
  int? _inches;
  int? _feet;

  @override
  void initState() {
    super.initState();

    _inches = widget.initialValue?.inches;
    _feet = widget.initialValue?.feet;
  }

  void _setInches(int newInches) {
    setState(() {
      _inches = newInches;
    });

    widget.updateHeight(_feet ?? 0, _inches);
  }

  void _setFeet(int newFeet) {
    setState(() {
      _feet = newFeet;
    });
    widget.updateHeight(_feet, _inches ?? 0);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Row(
      key: widget.key,
      children: [
        Flexible(
          child: TextFieldWrapped(
            initialValue: widget.initialValue?.feet.toString() ?? "",
            setField: (e) {
              if (e != "null") {
                _setFeet(int.parse(e));
              }
            },
            isNumberInput: true,
            labelText: 'Height Feet',
          ),
        ),
        Flexible(
          child: TextFieldWrapped(
            isNumberInput: true,

            initialValue: widget.initialValue?.inches.toString() ?? "",
            setField: (e) {
              if (e != "null") {
                _setInches(int.parse(e));
              }
            },
            labelText: 'Height Inches',
          ),
        ),
      ],
    );
  }
}
