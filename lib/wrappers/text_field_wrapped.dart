import 'package:flutter/material.dart';

class TextFieldWrapped extends StatefulWidget {
  const TextFieldWrapped({
    Key? key,
    this.maxLines,
    this.initialValue,
    this.autofocus,
    this.setField,
    this.validator,
    this.labelText,
    this.borderColor,
    this.autocorrect,
    this.autoCorrect,
    this.obscureText,
    this.enableSuggestions,
    this.icon,
  }) : super(key: key);

  final String? initialValue;
  final Color? borderColor;
  final String? labelText;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final bool? autofocus;
  final bool? autoCorrect;
  final setField;
  final IconData? icon;
  final validator;
  final int? maxLines;

  @override
  State<TextFieldWrapped> createState() => _TextFieldWrappedState();
}

class _TextFieldWrappedState extends State<TextFieldWrapped> {
  String? errorText = "";
  String? text = "";

  _setField(theText) {
    setState(() {
      text = theText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines ?? 1,
      autofocus: widget.autofocus ?? false,
      obscureText: widget.obscureText ?? false,
      enableSuggestions: widget.enableSuggestions ?? false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      autocorrect: widget.autocorrect ?? false,
      initialValue: widget.initialValue,
      onChanged: (e) {
        _setField(e);
        widget.setField(e);
      },
      decoration: InputDecoration(
        alignLabelWithHint: true,
        helperText: errorText,
        filled: true,
        fillColor: Colors.white70,
        prefixIcon: widget.icon!=null? Icon(widget.icon):null,
        border: OutlineInputBorder(
          borderSide: BorderSide( color: widget.borderColor??Colors.blue), //<-- SEE HERE
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(),
      ),
    );
  }
}
