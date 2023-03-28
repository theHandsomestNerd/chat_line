import 'package:chat_line/shared_components/menus/login_menu.dart';
import 'package:chat_line/wrappers/alerts_snackbar.dart';
import 'package:chat_line/wrappers/card_wrapped.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required, this.drawer});

  final drawer;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _loginUsername = "";
  String _loginPassword = "";
  AlertSnackbar _alertSnackbar = AlertSnackbar();

  @override
  void initState() {
    super.initState();

    _loginPassword = '';
    _loginUsername = '';
  }

  void _setUsername(String newUsername) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _loginUsername = newUsername;
    });
  }

  void _setPassword(String newPassword) {
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

      _alertSnackbar
          .showSuccessAlert("${credential.user?.email ?? ""}Logged In", context);
      Navigator.pushNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (kDebugMode) {
          print('No user found for that email.');
        }

        _alertSnackbar.showSuccessAlert("No user found for that email.", context);

        Navigator.pushNamed(context, '/');
      } else if (e.code == 'wrong-password') {
        if (kDebugMode) {
          print('Wrong password provided for that user.');
        }
        _alertSnackbar
            .showSuccessAlert("Wrong password provided for that user.", context);

        Navigator.pushNamed(context, '/');
      }
    }
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
      floatingActionButton: const LoginMenu(),
      drawer: widget.drawer,
      appBar: AppBar(
        // Here we take the value from the LoginPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Chat Line - Login"),
      ),
      body: CardWrapped(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Login',
              ),
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    TextFormField(
                      key: ObjectKey("$_loginUsername$_loginPassword-user"),
                      autofocus:
                          _loginPassword.isEmpty && _loginUsername.isNotEmpty,
                      initialValue: _loginUsername,
                      onChanged: (e) {
                        _setUsername(e);
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                    TextFormField(
                      key: ObjectKey("$_loginPassword$_loginUsername-pass"),
                      autofocus: _loginPassword.isNotEmpty &&
                          _loginUsername.isNotEmpty,
                      initialValue: _loginPassword,
                      onChanged: (e) {
                        _setPassword(e);
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    MaterialButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      // style: ButtonStyle(
                      //     backgroundColor: _isMenuItemsOnly
                      //         ? MaterialStateProperty.all(Colors.red)
                      //         : MaterialStateProperty.all(Colors.white)),
                      onPressed: () {
                        _loginUser(context);
                      },
                      child: const Text("Login"),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text("If you do not have an account..."),
                    MaterialButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      // style: ButtonStyle(
                      //     backgroundColor: _isMenuItemsOnly
                      //         ? MaterialStateProperty.all(Colors.red)
                      //         : MaterialStateProperty.all(Colors.white)),
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/register');
                      },
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}