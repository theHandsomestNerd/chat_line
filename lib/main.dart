import 'dart:async';

import 'package:cookowt/config/default_config.dart';
import 'package:cookowt/models/controllers/analytics_controller.dart';
import 'package:cookowt/models/controllers/auth_controller.dart';
import 'package:cookowt/models/controllers/chat_controller.dart';
import 'package:cookowt/models/controllers/geolocation_controller.dart';
import 'package:cookowt/models/controllers/post_controller.dart';
import 'package:cookowt/pages/hashtag_library_page.dart';
import 'package:cookowt/pages/hashtag_page.dart';
import 'package:cookowt/pages/home_page.dart';
import 'package:cookowt/pages/logout_page.dart';
import 'package:cookowt/pages/posts_page.dart';
import 'package:cookowt/pages/profiles_page.dart';
import 'package:cookowt/pages/register_page.dart';
import 'package:cookowt/pages/settings_page.dart';
import 'package:cookowt/pages/solo_post_page.dart';
import 'package:cookowt/pages/solo_profile_page.dart';
import 'package:cookowt/pages/splash_screen.dart';
import 'package:cookowt/shared_components/bug_reporter/bug_reporter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:universal_io/io.dart';

import 'config/firebase_options.dart';
import 'models/controllers/auth_inherited.dart';
import 'pages/login_page.dart';

// import '../../platform_dependent/image_uploader.dart'
//     if (dart.library.io) '../../platform_dependent/image_uploader_io.dart'
//     if (dart.library.html) '../../platform_dependent/image_uploader_html.dart';

Future<void> main() async {
  // await dotenv.load(mergeWith: Platform.environment, fileName: "assets/.env");
  // const _requiredEnvVars = const ['FIREBASE_PROJECT_ID', 'FIREBASE_APP_ID'];
  // bool get (hasEnv) => dotenv.isEveryDefined(_requiredEnvVars);

  // print("platform env vars${Platform.environment} ${dotenv.env}");
  usePathUrlStrategy();

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

  if (kDebugMode) {
    //Emulator setup
    await FirebaseAuth.instance
        .useAuthEmulator('127.0.0.1', 9099); //Error is thrown here
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter router = GoRouter(
    redirect: (BuildContext context, GoRouterState state) {
      // print("GO_ROUTER ${state.location} ${state.subloc}");
      if (state.subloc == '/register' || state.subloc == '/splash') {
        return null;
      }

      // if the user is not logged in, they need to login
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.subloc == '/login';

      // print("loggedIn ${loggedIn} loggingIn ${loggingIn}");

      if (!loggedIn) return loggingIn ? null : '/login';

      // if the user is logged in but still on the login page, send them to
      // the home page
      if (loggingIn) return '/home';

      // no need to redirect at all
      return null;
    },
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/logout',
        builder: (BuildContext context, GoRouterState state) {
          return const LogoutPage();
        },
      ),
      GoRoute(
        path: '/profilesPage',
        builder: (BuildContext context, GoRouterState state) {
          return ProfilesPage();
        },
      ),
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return SplashPage();
        },
      ),
      GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) =>
              HomePage()),
      GoRoute(
          path: '/postsPage',
          builder: (BuildContext context, GoRouterState state) =>
              PostsPage()),
      // GoRoute(
      //     path: '/createPostsPage',
      //     builder: (BuildContext context, GoRouterState state) =>
      //         BugReporter(child: CreatePostPage())),
      GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) =>
              RegisterPage()),
      GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) =>
              SettingsPage()),
      GoRoute(
          path: '/post/:id',
          builder: (BuildContext context, GoRouterState state) => SoloPostPage(
                thisPostId: state.params["id"],
              )),
      GoRoute(
          path: '/profile/:id',
          builder: (BuildContext context, GoRouterState state) {
            return SoloProfilePage(
              id: state.params["id"]!,
            );
          }),
      GoRoute(
          path: '/myProfile',
          builder: (BuildContext context, GoRouterState state) {
            return SoloProfilePage(
              id: FirebaseAuth.instance.currentUser?.uid ?? "",
            );
          }),
      GoRoute(
          path: '/hashtag/:id',
          builder: (BuildContext context, GoRouterState state) => HashtagPage(
                key: Key(state.params["id"]!),
                thisHashtagId: state.params["id"],
              )),
      GoRoute(
          path: '/hashtagCollections',
          builder: (BuildContext context, GoRouterState state) =>
              const HashtagLibraryPage()),
    ],
  );

  late AuthController authController = AuthController.init();
  late ChatController chatController = ChatController.init();
  late PostController postController = PostController.init();
  late AnalyticsController analyticsController = AnalyticsController.init();
  late GeolocationController geolocationController = GeolocationController();

  // var myExtProfile = null;

  // static bool isUserLoggedIn = false;

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

  @override
  void dispose() {
    geolocationController.dispose();
    super.dispose();
  }

  String id = "";

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies

    // var intermediate =
    //     AuthInherited.of(context)?.authController?.isLoggedIn ?? false;
    //
    // isUserLoggedIn = intermediate;

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
    super.didChangeDependencies();
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
      geolocationController: geolocationController,
      authController: authController,
      chatController: chatController,
      postController: postController,
      myLoggedInUser: authController.loggedInUser,
      profileImage: authController.myAppUser?.profileImage,
      child: MaterialApp.router(
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        // key: ObjectKey(isUserLoggedIn),
        // navigatorObservers: <NavigatorObserver>[routeObserver],
        title: 'Cookowt',
        // routes: {
        //   '/home': (context) {
        //     return const HomePage();
        //   },
        //   '/postsPage': (context) => const PostsPage(),
        //   '/createPostsPage': (context) =>
        //       const BugReporter(child: CreatePostPage()),
        //   '/register': (context) => const RegisterPage(),
        //   '/': (context) {
        //     if (kIsWeb) {
        //       // Define MetaSEO object
        //       MetaSEO meta = MetaSEO();
        //       // add meta seo data for web app as you want
        //       var title = 'Cookowt-The Invite Only Network';
        //       var image =
        //           "https://cdn.sanity.io/images/dhhk6mar/production/ae5b21a6e5982153e74ca8a815b90f92368ac9fa-3125x1875.png";
        //       var description =
        //           'Cookowt is the next invite only social media app. Invite only means real users unless they are admitted by someone already at the Cookowt. You will be able to link to other Social media to enable cross posting for those not invited. Want the invite? tweet @Cookowtinvitee';
        //       meta.ogTitle(ogTitle: title);
        //       meta.description(description: description);
        //       meta.keywords(keywords: 'social media, black twitter, memes');
        //       meta.twitterCard(twitterCard: TwitterCard.summaryLargeImage);
        //       meta.author(author: "The Handsomest Nerd");
        //       meta.twitterDescription(twitterDescription: description);
        //       meta.twitterImage(twitterImage: image);
        //       meta.twitterTitle(twitterTitle: title);
        //       meta.ogImage(ogImage: image);
        //     }
        //     return const LoginPage();
        //   },
        //   // '/editProfile': (context) => const EditProfilePage(),
        //   '/logout': (context) => const LogoutPage(),
        //   '/profilesPage': (context) => const ProfilesPage(),
        //   '/profile': (context) {
        //     var arguments = (ModalRoute.of(context)?.settings.arguments ??
        //         <String, dynamic>{}) as Map;
        //
        //     String theId;
        //     if (arguments['id'] != null) {
        //       theId = arguments['id'];
        //     } else {
        //       theId = authController.myAppUser?.userId.toString() ?? "";
        //     }
        //
        //     AppUser? thisProfile;
        //     for (var element in chatController.profileList) {
        //       if (element.userId == theId) {
        //         thisProfile = element;
        //       }
        //     }
        //
        //     return SoloProfilePage(
        //       thisProfile: thisProfile,
        //       key: ObjectKey(arguments["id"]),
        //       id: theId,
        //     );
        //   },
        //   '/post': (context) {
        //     var arguments = (ModalRoute.of(context)?.settings.arguments ??
        //         <String, dynamic>{}) as Map;
        //
        //     String? theId;
        //     if (arguments['id'] != null) {
        //       theId = arguments['id'];
        //     }
        //
        //     // var thisPost;
        //     // if (theId != null) {
        //     //    postController.getPost(theId).then((value){
        //     //     print("Post retrieved before ");
        //
        //     return SoloPostPage(
        //       thisPostId: theId,
        //     );
        //
        //     // }
        //     // return Placeholder();
        //   },
        //   '/myProfile': (context) {
        //     String theId = authController.myAppUser?.userId.toString() ?? "";
        //     AppUser? thisProfile;
        //     for (var element in chatController.profileList) {
        //       if (element.userId == theId) {
        //         thisProfile = element;
        //       }
        //     }
        //     return SoloProfilePage(
        //       thisProfile: thisProfile,
        //       id: theId,
        //     );
        //   },
        //   // '/postsPage': (context) {
        //   //   return PostsThreadPage(
        //   //     drawer: widget.drawer,
        //   //   );
        //   // },
        //   '/settings': (context) {
        //     return const SettingsPage();
        //   },
        // },
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
