import 'package:kookout/config/default_config.dart';
import 'package:kookout/models/controllers/analytics_controller.dart';
import 'package:kookout/shared_components/loading_logo.dart';
import 'package:kookout/shared_components/menus/login_menu.dart';
import 'package:kookout/wrappers/app_scaffold_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/controllers/auth_controller.dart';
import '../models/controllers/auth_inherited.dart';

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
  late AuthController authController;
  late AnalyticsController analyticsControllerController;
  late String sanityDB;
  late String apiVersion;
  late String sanityApiDB;

  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies() async {
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
      print("dependencies changed splash page");
    }
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

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: LoadingLogo(),
            ),
            Column(
              children: [
                Text(DefaultConfig.appName),
                Text(
                    "ui v${DefaultConfig.version}.${DefaultConfig.buildNumber} - ${DefaultConfig.sanityDB}"),
                Text("api - ${DefaultConfig.apiStatus}"),
                Text("v$apiVersion -$sanityApiDB"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
