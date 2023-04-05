import 'package:cookout/shared_components/bug_reporter/bug_reporter_open_button.dart';
import 'package:flutter/material.dart';

class BugReporter extends StatefulWidget {
  const BugReporter({Key? key, this.child}) : super(key: key);

  final child;

  @override
  State<BugReporter> createState() => _BugReporterState();
}

class _BugReporterState extends State<BugReporter> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Padding(
          padding: const EdgeInsets.fromLTRB(0,108.0,0,0),
          child: BugReporterOpenButton(),
        ),
      ],
    );
  }
}
