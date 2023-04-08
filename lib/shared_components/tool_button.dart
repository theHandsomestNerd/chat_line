import 'package:flutter/material.dart';

class ToolButton extends StatefulWidget {
  const ToolButton(
      {super.key,
      this.defaultColor,
      required this.action,
      required this.iconData,
      required this.color,
      required this.label,
      this.isHideLabel,
      this.isLoading,
      this.isDisabled,
      this.text,
      this.isActive});

  final String label;
  final bool? isHideLabel;
  final bool? isDisabled;
  final String? text;
  final action;
  final IconData iconData;
  final Color color;
  final Color? defaultColor;
  final bool? isActive;
  final bool? isLoading;

  @override
  State<ToolButton> createState() => _ToolButtonState();
}

class _ToolButtonState extends State<ToolButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: Key(widget.text ?? ""),
      onPressed: widget.isDisabled != true
          ? () {
              widget.action(context);
            }
          : null,
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.isLoading != true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        widget.iconData,
                        color: widget.isActive == true
                            ? widget.color
                            : widget.defaultColor ?? Colors.black,
                        size: 20,
                        semanticLabel: widget.label,
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(
                        color:
                            widget.isActive == true ? widget.color : Colors.white,
                      ),
                    ),
                  ),
            if (widget.isHideLabel != true)
              const SizedBox(
                width: 16,
              ),
            if (widget.isHideLabel != true)
              Text(
                key: Key(widget.text ?? "0"),
                widget.text ?? "0",
                style: Theme.of(context).textTheme.labelLarge?.merge(
                      TextStyle(
                        // fontSize: ((widget.text?.length ?? 0) > 4) ? 16 : 16,
                        color: widget.isActive == true
                            ? widget.color
                            : widget.defaultColor ?? Colors.black,
                      ),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
