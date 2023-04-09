import 'package:cookout/config/default_config.dart';
import 'package:cookout/models/controllers/analytics_controller.dart';
import 'package:cookout/shared_components/logo.dart';
import 'package:cookout/shared_components/menus/login_menu.dart';
import 'package:cookout/wrappers/alerts_snackbar.dart';
import 'package:cookout/wrappers/analytics_loading_button.dart';
import 'package:cookout/wrappers/text_field_wrapped.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/controllers/auth_controller.dart';
import '../models/controllers/auth_inherited.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    apiVersion = DefaultConfig.apiVersion ?? "no version";
    sanityApiDB = DefaultConfig.apiSanityDB ?? "no api env";
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
      Navigator.pushNamed(context, '/home');
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

  String? errorText = null;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      floatingActionButton: LoginMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        // Here we take the value from the LoginPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Logo(),
      ),
      body: Flex(
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  child: Image.asset('assets/logo.png'),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: 350, maxHeight: 450),
                                  child: Flex(
                                    direction: Axis.vertical,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: TextFieldWrapped(
                                          icon: Icons.person,
                                          autofocus: _loginPassword.isEmpty,
                                          validator: (String? value) {
                                            const pattern =
                                                r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                                                r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                                                r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                                                r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                                                r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                                                r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                                                r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
                                            final regex = RegExp(pattern);

                                            return value!.isNotEmpty &&
                                                    !regex.hasMatch(value)
                                                ? 'Enter a valid email address'
                                                : null;
                                          },
                                          autocorrect: false,
                                          initialValue: _loginUsername,
                                          setField: (e) {
                                            _setUsername(e);
                                          },
                                          labelText: "Username/Email",
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: TextFieldWrapped(
                                          icon: Icons.password,
                                          obscureText: true,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          setField: (e) {
                                            _setPassword(e);
                                          },
                                          initialValue: _loginPassword,
                                          labelText: "Password",
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: AnalyticsLoadingButton(
                                          analyticsEventName:
                                              'login-button-pressed',
                                          analyticsEventData: {
                                            "username": _loginUsername
                                          },
                                          isDisabled: _loginUsername.isEmpty ||
                                              _loginPassword.isEmpty,
                                          action: (innerContext) async {
                                             _loginUser(innerContext);
                                          },
                                          text: "Login",
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 32,
                                      ),
                                      const Flexible(
                                        flex: 1,
                                        child: Text(
                                            "If you do not have an account..."),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: AnalyticsLoadingButton(
                                          analyticsEventName:
                                              'login-register-button-pressed',
                                          analyticsEventData: {
                                            "username": _loginUsername
                                          },
                                          action: (innerContext) async {
                                            Navigator.pushNamed(
                                                innerContext, '/register');
                                          },
                                          text: "Register",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 32.0),
                            child: Column(
                              children: [
                                Text("${DefaultConfig.appName}"),
                                Text(
                                    "ui v${DefaultConfig.version}.${DefaultConfig.buildNumber} - ${DefaultConfig.sanityDB}"),
                                Text("api - ${DefaultConfig.apiStatus}"),
                                Text("v${apiVersion} -${sanityApiDB}"),
                              ],
                            ),
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
