import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsController {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  AnalyticsController.init() {}

  // Future<void> _setDefaultEventParameters() async {
  //   if (kIsWeb) {
  //     setMessage(
  //       '"setDefaultEventParameters()" is not supported on web platform',
  //     );
  //   } else {
  //     // Only strings, numbers & null (longs & doubles for android, ints and doubles for iOS) are supported for default event parameters:
  //     await analytics.setDefaultEventParameters(<String, dynamic>{
  //       'string': 'string',
  //       'int': 42,
  //       'long': 12345678910,
  //       'double': 42.0,
  //       'bool': true.toString(),
  //     });
  //     setMessage('setDefaultEventParameters succeeded');
  //   }
  // }

  Future<void> sendAnalyticsEvent(String eventName, Map<String, dynamic> event) async {
    // Only strings and numbers (longs & doubles for android, ints and doubles for iOS) are supported for GA custom event parameters:
    // https://firebase.google.com/docs/reference/ios/firebaseanalytics/api/reference/Classes/FIRAnalytics#+logeventwithname:parameters:
    // https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics#public-void-logevent-string-name,-bundle-params
    try {
      await analytics.logEvent(
        name: eventName,
        parameters: {...event},
        // <String, dynamic>{
        //   'string': 'string',
        //   'int': 42,
        //   'long': 12345678910,
        //   'double': 42.0,
        //   // Only strings and numbers (ints & doubles) are supported for GA custom event parameters:
        //   // https://developers.google.com/analytics/devguides/collection/analyticsjs/custom-dims-mets#overview
        //   'bool': true.toString(),
        // },
      );
    }catch(e){
      print("Analytics error $e");
    }

    print('logEvent succeeded');
  }

  Future<void> setUserId(String userId) async {
    await analytics.setUserId(id: userId);
    print('setUserId succeeded');
  }

  Future<void> _testSetCurrentScreen(String screen) async {
    await analytics.setCurrentScreen(
      screenName: screen,
      screenClassOverride: 'AnalyticsDemo',
    );
    print('setCurrentScreen succeeded');
  }

  // Future<void> _testSetAnalyticsCollectionEnabled() async {
  // await analytics.setAnalyticsCollectionEnabled(false);
  // await analytics.setAnalyticsCollectionEnabled(true);
  // print('setAnalyticsCollectionEnabled succeeded');
  // }

  Future<void> _setSessionTimeoutDuration(int duration) async {
    return analytics
        .setSessionTimeoutDuration(Duration(milliseconds: duration));
    print('setSessionTimeoutDuration succeeded');
  }

  Future<void> _testSetUserProperty() async {
    await analytics.setUserProperty(name: 'regular', value: 'indeed');
    print('setUserProperty succeeded');
  }

  Future<void> _testResetAnalyticsData() async {
    await analytics.resetAnalyticsData();
    print('resetAnalyticsData succeeded');
  }

  Future<void> _testAppInstanceId() async {
    String? id = await analytics.appInstanceId;
    if (id != null) {
      print('appInstanceId succeeded: $id');
    } else {
      print('appInstanceId failed, consent declined');
    }
  }

  Future<void> logOpenApp() async {
    return analytics.logAppOpen();
  }

  Future<void> logLogin() async {
    return analytics.logLogin(loginMethod: 'login');
  }

  Future<void> logScreenView(String screenName) async {
    return analytics.logScreenView(
      screenName: screenName,
    );
  }

  Future<void> logSignUp(String method) async {
    return analytics.logSignUp(
      signUpMethod: method,
    );
  }

  Future<void> logSearch(String searchTerm) async {
    //   return  analytics.logSearch(
    //     searchTerm: 'hotel',
    //     numberOfNights: 2,
    //     numberOfRooms: 1,
    //     numberOfPassengers: 3,
    //     origin: 'test origin',
    //     destination: 'test destination',
    //     startDate: '2015-09-14',
    //     endDate: '2015-09-16',
    //     travelClass: 'test travel class',
    //   );
    await analytics.logViewSearchResults(
      searchTerm: searchTerm,
    );
  }

// Future<void> _testAllEventTypes() async {
// await analytics.logCampaignDetails(
//   source: 'source',
//   medium: 'medium',
//   campaign: 'campaign',
//   term: 'term',
//   content: 'content',
//   aclid: 'aclid',
//   cp1: 'cp1',
// );

// await analytics.logTutorialBegin();
// await analytics.logTutorialComplete();
// await analytics.logUnlockAchievement(id: 'all Firebase API covered');
// }
}
