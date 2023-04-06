import 'package:cookout/wrappers/alerts_snackbar.dart';
import 'package:cookout/wrappers/text_field_wrapped.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/default_config.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../shared_components/logo.dart';
import '../shared_components/menus/login_menu.dart';
import '../wrappers/loading_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _loginUsername = "";
  String _loginPassword = "";

  late AnalyticsController analyticsController;

  @override
  void initState() {
    super.initState();

    _loginPassword = '';
    _loginUsername = '';
  }

  didChangeDependencies() async {
    super.didChangeDependencies();
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    theAnalyticsController?.logScreenView('Register');
    if (theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
    }


  }

  Future<void> _setUsername(String newUsername) async {
    if(newUsername.length == 1) {
      await analyticsController.sendAnalyticsEvent('registration-username', {'event': "started_typing"});
    }

    if(!(_loginUsername.isEmpty ||
        _loginPassword.isEmpty)) {
      await analyticsController.sendAnalyticsEvent('registration-form-enabled', {'username': _loginUsername});
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

  void _setPassword(String newPassword) async  {
    if(newPassword.length == 1) {
      await analyticsController.sendAnalyticsEvent('RegistrationPasswordField', {'event': "started_typing"});
    }
    if(!(_loginUsername.isEmpty ||
        _loginPassword.isEmpty)) {
      await analyticsController.sendAnalyticsEvent('registration-form-enabled', {'username': _loginUsername});
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

  bool isLoading = false;

  Future<void> _registerUser(context) async {
    setState(() {
      isLoading = true;
    });
    try {
      // if (kDebugMode) {
      //   print("authcontroller ${AuthInherited.of(context)?.authController}");
      // }
      await AuthInherited.of(context)
          ?.authController
          ?.registerUser(_loginUsername, _loginPassword, context);
      // if (kDebugMode) {
      //   print(myAppUser);
      // }
      await analyticsController.logSignUp("email");

      setState(() {
        isLoading = true;
      });
      Navigator.popAndPushNamed(context, '/settings');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        isLoading = true;
      });
    }

    AlertSnackbar().showSuccessAlert(
        'Account Created...Take a second to Fill in your profile.', context);

    return;
  }

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
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/221.jpg',
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 150,
                              width: 300,
                              child: Image.asset('assets/logo.png'),
                            ),
                            SizedBox(
                              width: 350,
                              child: Column(
                                children: [
                                  TextFieldWrapped(
                                    labelText: "Username/Email",
                                    icon: Icons.person,
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
                                    setField: (e) {
                                      _setUsername(e);
                                    },
                                    autofocus: _loginPassword.isEmpty,
                                    autocorrect: false,
                                    initialValue: _loginUsername,
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  TextFieldWrapped(
                                    obscureText: true,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    initialValue: _loginPassword,
                                    icon: Icons.password,
                                    labelText: "Password",
                                    setField: (e) {
                                      _setPassword(e);
                                    },
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  LoadingButton(
                                    isDisabled: _loginUsername.isEmpty ||
                                        _loginPassword.isEmpty,
                                    isLoading: isLoading,
                                    action: () {
                                      _registerUser(context);
                                    },
                                    text: "Register",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
