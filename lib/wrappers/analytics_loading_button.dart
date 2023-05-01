import 'package:cookowt/models/controllers/analytics_controller.dart';
import 'package:cookowt/models/controllers/auth_inherited.dart';
import 'package:cookowt/wrappers/loading_button.dart';
import 'package:flutter/material.dart';

class AnalyticsLoadingButton extends StatefulWidget {
  const AnalyticsLoadingButton(
      {super.key,
      this.action,
      required this.analyticsEventName,
      required this.analyticsEventData,
      this.text,
      this.isDisabled,
      this.width});

  final Function? action;
  final double? width;
  final bool? isDisabled;
  final String? text;
  final String analyticsEventName;
  final Map<String, dynamic> analyticsEventData;

  @override
  State<AnalyticsLoadingButton> createState() => _AnalyticsLoadingButtonState();
}

class _AnalyticsLoadingButtonState extends State<AnalyticsLoadingButton> {
  bool isLoading = false;
  late AnalyticsController analyticsController;

  @override
  didChangeDependencies() async {

    var theAnalyticsController = AuthInherited.of(context)?.analyticsController;
    if (theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
      setState(() {});
    }
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      text: widget.text,
      isLoading: isLoading,
      isDisabled: widget.isDisabled,
      action: (context) async {
        setState(() {
          isLoading = true;
        });

        await analyticsController.sendAnalyticsEvent(
            widget.analyticsEventName, widget.analyticsEventData);

        if (widget.action != null) {
          await widget.action!(context);
        }

        setState(() {
          isLoading = false;
        });
      },
    );
  }
}
