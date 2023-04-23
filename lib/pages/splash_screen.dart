import 'package:cookowt/config/default_config.dart';
import 'package:cookowt/models/controllers/analytics_controller.dart';
import 'package:cookowt/shared_components/menus/login_menu.dart';
import 'package:cookowt/wrappers/alerts_snackbar.dart';
import 'package:cookowt/wrappers/analytics_loading_button.dart';
import 'package:cookowt/wrappers/app_scaffold_wrapper.dart';
import 'package:cookowt/wrappers/text_field_wrapped.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/controllers/auth_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../shared_components/tool_button.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late String appName;
  late String packageName;
  late String version;
  late String buildNumber;
  String _loginUsername = "";
  String _loginPassword = "";
  late AuthController authController;
  late AnalyticsController analyticsControllerController;
  final AlertSnackbar _alertSnackbar = AlertSnackbar();
  late String sanityDB;
  late String apiVersion;
  late String sanityApiDB;

  @override
  void initState() {
    super.initState();

    _loginPassword = '';
    _loginUsername = '';
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    AuthController? theAuthController =
        AuthInherited.of(context)?.authController;
    if (theAuthController != null) {
      authController = theAuthController;
    }
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    if (theAnalyticsController != null) {
      analyticsControllerController = theAnalyticsController;
    }
    theAnalyticsController?.logScreenView('Login');
    apiVersion = DefaultConfig.apiVersion;
    sanityApiDB = DefaultConfig.apiSanityDB;
    setState(() {});
    if (kDebugMode) {
      print("dependencies changed login page");
    }
  }

  void _setUsername(String newUsername) async {
    if (newUsername.length == 1) {
      await analyticsControllerController
          .sendAnalyticsEvent('login-username', {'event': "started_typing"});
    }

    if (!(_loginUsername.isEmpty || _loginPassword.isEmpty)) {
      await analyticsControllerController.sendAnalyticsEvent(
          'login-form-enabled', {'username': _loginUsername});
    }
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _loginUsername = newUsername;
    });
  }

  void _setPassword(String newPassword) async {
    if (newPassword.length == 1) {
      await analyticsControllerController.sendAnalyticsEvent(
          'login-password-field', {'event': "started_typing"});
    }
    if (!(_loginUsername.isEmpty || _loginPassword.isEmpty)) {
      await analyticsControllerController.sendAnalyticsEvent(
          'login-form-enabled', {'username': _loginUsername});
    }
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _loginPassword = newPassword;
    });
  }

  void _loginUser(context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _loginUsername,
        password: _loginPassword,
      );
      if (kDebugMode) {
        print(credential);
      }

      _alertSnackbar.showSuccessAlert(
          "${credential.user?.email ?? ""}Logged In", context);
      GoRouter.of(context).go('/home');

      // Navigator.pushNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (kDebugMode) {
          print('No user found for that email.');
        }

        _alertSnackbar.showSuccessAlert(
            "No user found for that email.", context);

        // Navigator.pushNamed(context, '/');
      } else if (e.code == 'wrong-password') {
        if (kDebugMode) {
          print('Wrong password provided for that user.');
        }
        _alertSnackbar.showSuccessAlert(
            "Wrong password provided for that user.", context);

        // Navigator.pushNamed(context, '/');
      }
    }
  }

  String? errorText;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return AppScaffoldWrapper(
      floatingActionMenu: const LoginMenu(),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            child: Center(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/221.jpg',
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                  Center(
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 8,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  height: 150,
                                  width: 300,
                                  child: Image.asset('assets/logo-w.png'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(DefaultConfig.appName),
                              Text(
                                  "ui v${DefaultConfig.version}.${DefaultConfig.buildNumber} - ${DefaultConfig.sanityDB}"),
                              Text("api - ${DefaultConfig.apiStatus}"),
                              Text("v$apiVersion -$sanityApiDB"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
