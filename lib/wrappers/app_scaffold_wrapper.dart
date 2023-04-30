import 'package:kookout/shared_components/bug_reporter/bug_reporter.dart';
import 'package:kookout/shared_components/logo.dart';
import 'package:flutter/material.dart';

class AppScaffoldWrapper extends StatelessWidget {
  const AppScaffoldWrapper({Key? key, this.floatingActionMenu, this.child})
      : super(key: key);

  final Widget? floatingActionMenu;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BugReporter(
      child: Scaffold(
        floatingActionButton: floatingActionMenu,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.5),
          title: const Logo(),
        ),
        body: child,
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
