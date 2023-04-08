import 'dart:async';
import 'dart:convert';

import 'package:cookout/config/default_config.dart';
import 'package:cookout/models/controllers/analytics_controller.dart';
import 'package:cookout/models/controllers/auth_controller.dart';
import 'package:cookout/models/controllers/chat_controller.dart';
import 'package:cookout/models/controllers/post_controller.dart';
import 'package:cookout/pages/create_post_page.dart';
import 'package:cookout/pages/home_page.dart';
import 'package:cookout/pages/logout_page.dart';
import 'package:cookout/pages/posts_page.dart';
import 'package:cookout/pages/profiles_page.dart';
import 'package:cookout/pages/register_page.dart';
import 'package:cookout/pages/settings_page.dart';
import 'package:cookout/pages/solo_profile_page.dart';
import 'package:cookout/shared_components/bug_reporter/bug_reporter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:package_info_plus_web/package_info_plus_web.dart';

import 'config/firebase_options.dart';
import 'models/controllers/auth_inherited.dart';
import 'pages/login_page.dart';

// import '../../platform_dependent/image_uploader.dart'
//     if (dart.library.io) '../../platform_dependent/image_uploader_io.dart'
//     if (dart.library.html) '../../platform_dependent/image_uploader_html.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // Ideal time to initialize
  if (kIsWeb) {
    MetaSEO().config();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  DefaultConfig();
  await DefaultConfig.initializingConfig;

  print("main auth url ${DefaultConfig.theAuthBaseUrl}");

  if (kDebugMode) {
    //Emulator setup
    await FirebaseAuth.instance
        .useAuthEmulator('127.0.0.1', 9099); //Error is thrown here
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthController authController = AuthController.init();
  late ChatController chatController = ChatController.init();
  late PostController postController = PostController.init();
  late AnalyticsController analyticsController = AnalyticsController.init();

  // var myExtProfile = null;

  bool isUserLoggedIn = false;

  String appName = "";
  String packageName = "";
  String version = "";
  String apiVersion = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    analyticsController.logOpenApp();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (kDebugMode) {
          print('postController: User is currently signed out!');
        }
      } else {
        if (kDebugMode) {
          print('postController: User is signed in!');
        }
        analyticsController.logLogin();
        analyticsController.setUserId(user.uid);
      }
    });
  }

  String id = "";

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    var intermediate =
        AuthInherited.of(context)?.authController?.isLoggedIn ?? false;

    isUserLoggedIn = intermediate;

    var theAppVersion = DefaultConfig.version;

    appName = DefaultConfig.appName;
    packageName = DefaultConfig.packageName;
    version = theAppVersion;
    apiVersion = DefaultConfig.apiVersion;
    buildNumber = DefaultConfig.buildNumber;
    // if (kDebugMode) {
    //   print(
    //       "UI Version: ${DefaultConfig.version}.${DefaultConfig.buildNumber}");
    //   print("appName: ${DefaultConfig.appName}");
    //   print("packageName: ${DefaultConfig.packageName}");
    // }

    setState(() {});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AuthInherited(
      apiVersion: apiVersion,
      appName: appName,
      packageName: packageName,
      version: version,
      buildNumber: buildNumber,
      analyticsController: analyticsController,
      authController: authController,
      chatController: chatController,
      postController: postController,
      myLoggedInUser: authController.loggedInUser,
      profileImage: authController.myAppUser?.profileImage,
      child: MaterialApp(
        key: ObjectKey(isUserLoggedIn),
        title: 'Cookout',
        routes: {
          '/home': (context) {
            return BugReporter(child: HomePage());
          },
          '/postsPage': (context) => BugReporter(child: PostsPage()),
          '/createPostsPage': (context) => BugReporter(child: CreatePostPage()),
          '/register': (context) => BugReporter(child: RegisterPage()),
          '/': (context) {
            if (kIsWeb) {
              // Define MetaSEO object
              MetaSEO meta = MetaSEO();
              // add meta seo data for web app as you want
              var title = 'Cookout-The Invite Only Social Media Network';
              var image =
                  "https://cdn.sanity.io/images/dhhk6mar/production/ae5b21a6e5982153e74ca8a815b90f92368ac9fa-3125x1875.png";
              var description =
                  'Cookout is the next invite only social media app. Invite only means real users unless they are admitted by someone already at the Cookout. You will be able to link to other Social media to enable cross posting for those not invited. Want the invite? tweet @Cookoutinvitee';
              meta.ogTitle(ogTitle: title);
              meta.description(description: description);
              meta.keywords(keywords: 'social media, black twitter, memes');
              meta.twitterCard(twitterCard: TwitterCard.summaryLargeImage);
              meta.author(author: "The Handsomest Nerd");
              meta.twitterDescription(twitterDescription: description);
              meta.twitterImage(twitterImage: image);
              meta.twitterTitle(twitterTitle: title);
              meta.ogImage(ogImage: image);
            }
            return BugReporter(
              child: LoginPage(),
            );
          },
          // '/editProfile': (context) => const EditProfilePage(),
          '/logout': (context) => BugReporter(child: LogoutPage()),
          '/profilesPage': (context) => BugReporter(child: ProfilesPage()),
          '/profile': (context) {
            var arguments = (ModalRoute.of(context)?.settings.arguments ??
                <String, dynamic>{}) as Map;

            var theId;
            if (arguments['id'] != null) {
              theId = arguments['id'];
            } else {
              theId = authController.myAppUser?.userId.toString() ?? "";
            }

            var thisProfile = null;
            for (var element in chatController.profileList) {
              if (element.userId == theId) {
                thisProfile = element;
              }
            }

            return BugReporter(
              child: SoloProfilePage(
                thisProfile: thisProfile,
                key: ObjectKey(arguments["id"]),
                id: theId,
              ),
            );
          },
          '/myProfile': (context) {
            var theId = authController.myAppUser?.userId.toString() ?? "";
            var thisProfile = null;
            chatController.profileList.forEach((element) {
              if (element.userId == theId) {
                thisProfile = element;
              }
            });
            return BugReporter(
              child: SoloProfilePage(
                thisProfile: thisProfile,
                id: theId,
              ),
            );
          },
          // '/postsPage': (context) {
          //   return PostsThreadPage(
          //     drawer: widget.drawer,
          //   );
          // },
          '/settings': (context) {
            return BugReporter(child: SettingsPage());
          },
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.red,
            brightness: Brightness.light,
            accentColor: Colors.black,
          ),
          primaryColor: Colors.red,
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          textTheme: const TextTheme(
            displayLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 36.0),
            titleSmall: TextStyle(fontSize: 22.0),
            bodyLarge: TextStyle(fontSize: 18.0, fontFamily: 'Hind'),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
          // primarySwatch: Colors.grey,
        ),
      ),
    );
  }
}
