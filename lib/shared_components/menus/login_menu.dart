import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../wrappers/expanding_fab.dart';

class LoginMenu extends StatefulWidget {
  const LoginMenu({Key? key   
  }) : super(key: key);

  

  @override
  State<LoginMenu> createState() => _LoginMenuState();
}

class _LoginMenuState extends State<LoginMenu> {
  User? myAppUser;

  @override
  didChangeDependencies() async {
    myAppUser = FirebaseAuth.instance.currentUser;
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
     
      distance: 62.0,
      children: [
        if (myAppUser != null)
          ActionButton(
            tooltip: "Logout",
            onPressed: () {
              GoRouter.of(context).go('/logout');

              // Navigator.popAndPushNamed(context, '/logout');
            },
            icon: const Icon(Icons.logout),
          ),
        if (myAppUser != null)
          ActionButton(
            tooltip: "Profiles",
            onPressed: () {
              GoRouter.of(context).go('/profilesPage');

              // Navigator.popAndPushNamed(context, '/profilesPage');
            },
            icon: const Icon(Icons.people),
          ),
        if (myAppUser != null)
          ActionButton(
            tooltip: "Posts",
            onPressed: () {
              GoRouter.of(context).go('/postsPage');

              // Navigator.popAndPushNamed(context, '/postsPage');
            },
            icon: const Icon(Icons.post_add),
          ),
        if (myAppUser == null)
          ActionButton(
            tooltip: "Login",
            onPressed: () {
              GoRouter.of(context).go('/login');

              // Navigator.popAndPushNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
          ),
        if (myAppUser != null)
          ActionButton(
            tooltip: "Home",
            onPressed: () {
              GoRouter.of(context).go('/home');

              // Navigator.popAndPushNamed(context, '/home');
            },
            icon: const Icon(Icons.home),
          ),
        if (myAppUser == null)
          ActionButton(
            tooltip: "Register",
            onPressed: () {
              GoRouter.of(context).go('/register');

              // Navigator.popAndPushNamed(context, '/register');
            },
            icon: const Icon(Icons.app_registration),
          ),
      ],
    );
  }
}
