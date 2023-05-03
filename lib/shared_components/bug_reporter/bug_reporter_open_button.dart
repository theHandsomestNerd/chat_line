import 'package:cookowt/shared_components/bug_reporter/bug_reporter_content.dart';
import 'package:flutter/material.dart';

class BugReporterOpenButton extends StatefulWidget {
  const BugReporterOpenButton({Key? key}) : super(key: key);

  @override
  State<BugReporterOpenButton> createState() => _BugReporterOpenButtonState();
}


class _BugReporterOpenButtonState extends State<BugReporterOpenButton> {

  _openDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
          return const BugReporterContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Report a Bug",
      child: Container(
        transform: Matrix4.translationValues(
            -32, 0, .0),
        child: MaterialButton(
            color: Colors.green.withOpacity(.8),
            child: SizedBox(
              height: 48,
              width: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.bug_report_outlined),
                ],
              ),
            ),
            onPressed: () async {
              //open dialog
              _openDialog();
            }),
      ),
    );
  }
}
