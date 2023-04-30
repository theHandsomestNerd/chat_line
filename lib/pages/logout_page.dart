import 'package:kookout/wrappers/app_scaffold_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../wrappers/analytics_loading_button.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({
    super.key,
  });

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  didChangeDependencies() async {

    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    theAnalyticsController?.logScreenView('Logout');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return AppScaffoldWrapper(
      child: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/221.jpg',
            repeat: ImageRepeat.repeat,
          ),
        ),
        Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (FirebaseAuth.instance.currentUser != null)
                          Text(
                              "Logout ${FirebaseAuth.instance.currentUser?.email}")
                      ],
                    ),
                    const SizedBox(height: 32,),
                    AnalyticsLoadingButton(
                      action: (innerContext) async {
                        await FirebaseAuth.instance.signOut().then((x) {
                          GoRouter.of(context).go('/');

                        });
                      },
                      analyticsEventName: 'logout-page-logout-press',
                      analyticsEventData: {
                        "username": FirebaseAuth.instance.currentUser?.uid ??
                            "No Logged In User",
                      },
                      text: "Logout",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
