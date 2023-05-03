import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.minLines,
    this.enableSuggestions,
    this.icon,
    this.enabled,
    this.isNumberInput
  }) : super(key: key);

  final bool? isNumberInput;
  final String? initialValue;
  final Color? borderColor;
  final String? labelText;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final bool? autofocus;
  final bool? autoCorrect;
  final bool? enabled;
  final Function? setField;
  final IconData? icon;
  final Function? validator;
  final int? maxLines;
  final int? minLines;

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
      key: widget.key,
      inputFormatters: widget.isNumberInput == true ? <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ]:null,
      enabled: widget.enabled ?? true,
      maxLines: widget.maxLines ?? 1,
      minLines: widget.minLines ?? 1,
      autofocus: widget.autofocus ?? false,
      obscureText: widget.obscureText ?? false,
      enableSuggestions: widget.enableSuggestions ?? false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (x) {
        if (widget.validator != null) {
          return widget.validator!(x);
        }
        return "";
      },
      autocorrect: widget.autocorrect ?? false,
      initialValue: widget.initialValue,
      onChanged: (e) {
        _setField(e);
        widget.setField!(e);
      },
      decoration: InputDecoration(
        alignLabelWithHint: true,
        helperText: errorText,
        filled: true,
        fillColor: Colors.white70,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor ?? Colors.blue),
          //<-- SEE HERE
          borderRadius: const BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        labelText: widget.labelText,
        labelStyle: const TextStyle(),
      ),
    );
  }
}
