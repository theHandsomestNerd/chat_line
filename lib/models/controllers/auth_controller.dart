import 'dart:convert';

import 'package:cookowt/config/default_config.dart';
import 'package:cookowt/models/auth/auth_user.dart';
import 'package:cookowt/wrappers/alerts_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../app_user.dart';

class AuthController with ChangeNotifier {
  final AlertSnackbar _alertSnackbar = AlertSnackbar();

  String authBaseUrl = "";

  late bool isLoggedIn = false;
  AuthUser? loggedInUser;
  AppUser? myAppUser;

  AuthController.init() {
    authBaseUrl = DefaultConfig.theAuthBaseUrl;
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (kDebugMode) {
          print('authController: User is currently signed out!');
        }
        isLoggedIn = false;
        loggedInUser = null;
        myAppUser = null;
      } else {
        if (kDebugMode) {
          print('authController: User is signed in!');
        }
        isLoggedIn = true;

        loggedInUser ??= await _getLoggedInUser();

        myAppUser ??= await _getMyAppUser();
      }
    });

    if (FirebaseAuth.instance.currentUser != null) {
      isLoggedIn = true;
      _getMyAppUser().then((user) {
        myAppUser = user;
      });

      _getLoggedInUser().then((user) {
        if (user != null) {
          isLoggedIn = true;
        } else {
          isLoggedIn = false;
          myAppUser = null;
        }
        loggedInUser = user;
      });
    } else {
      isLoggedIn = false;
      myAppUser = null;
      loggedInUser = null;
    }
  }

  registerUser(String username, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: username,
        password: password,
      );
      if (kDebugMode) {
        print("Registering user $username");
      }

      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null && DefaultConfig.theAuthBaseUrl != "") {
        final response = await http.post(
            Uri.parse("${DefaultConfig.theAuthBaseUrl}/register-app-user"),
            headers: {"Authorization": ("Bearer $token")});

        dynamic processedResponse = jsonDecode(response.body);
        if (kDebugMode) {
          print("processedResponse ${processedResponse['profile']}");
        }

        AppUser myAppProfile = AppUser.fromJson(processedResponse['profile']);

        myAppUser = myAppProfile;

        if (kDebugMode) {
          print("Auth api response $myAppProfile");
        }
        return myAppProfile;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('authController: The password provided is too weak.');
        }
        _alertSnackbar.showErrorAlert("The Password is too weak.", context);
        return Exception("Password is too weak");
      } else if (e.code == 'email-already-in-use') {
        _alertSnackbar.showErrorAlert("Email Address already in use", context);
        return Exception("Email Address already in use");
      } else if (e.code == 'invalid-email') {
        _alertSnackbar.showErrorAlert(
            "The email aadress is badly formatted.", context);
        return Exception('invalid-email');
      }
    }
  }

  Future<AuthUser?> updateUser(String? username, String? displayName,
      String filename, fileBytes, BuildContext context) async {
    if(username == null || displayName==null){
      return null;
    }


    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null && DefaultConfig.theAuthBaseUrl != null) {
      var request = http.MultipartRequest(
          'POST', Uri.parse("${DefaultConfig.theAuthBaseUrl}/update-user-profile"));

      request.headers.addAll({"authorization": "Bearer $token"});

      if (filename != "") {
        request.files.add(http.MultipartFile.fromBytes('file', fileBytes,
            contentType: MediaType('application', 'octet-stream'),
            filename: filename));
      }

      if (loggedInUser?.email != username) {
        request.fields['email'] = username;
      }

      if (loggedInUser?.displayName != displayName) {
        request.fields['displayName'] = displayName;
      }

      await request.send();
      // if (kDebugMode) {
      //   print("Auth api response$response");
      // }
      var myUser = await _getMyAppUser();
      var authUser = await _getLoggedInUser();
      myAppUser = myUser;
      loggedInUser = authUser;
      return authUser;
    } else {
      if (kDebugMode) {
        print("Cannot update user no token present...");
      }
    }
    return null;
  }

  Future<AppUser?> _getMyAppUser() async {
    if (kDebugMode) {
      print(
          "Retrieving My App Profile ${loggedInUser?.uid} ${FirebaseAuth.instance.currentUser?.email ?? ""}");
    }
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (FirebaseAuth.instance.currentUser != null && token != null && DefaultConfig.theAuthBaseUrl != null) {
      final response = await http.get(Uri.parse("${DefaultConfig.theAuthBaseUrl}/get-my-profile"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse;
      try {
        processedResponse = jsonDecode(response.body);
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
        if (kDebugMode) {
          print("Processed response $processedResponse");
        }
      }
      if ( processedResponse!= null && processedResponse['myAppProfile'] != null) {
        AppUser responseModel =
            AppUser.fromJson(processedResponse['myAppProfile']);
        // if (kDebugMode) {
        //   print("gey app user Auth api response $responseModel");
        // }

        myAppUser = responseModel;

        return responseModel;
      }
    }

    return null;
  }

  Future<AuthUser?> _getLoggedInUser() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (FirebaseAuth.instance.currentUser == null && token != null && DefaultConfig.theAuthBaseUrl != "") {
      if (kDebugMode) {
        print(
            "Retrieving My Auth Profile ${FirebaseAuth.instance.currentUser?.uid ?? ""}");
      }
      final response = await http.get(Uri.parse("${DefaultConfig.theAuthBaseUrl}/get-auth-user"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);

      AuthUser responseModel =
          AuthUser.fromJson(processedResponse['myAuthProfile']);
      // if (kDebugMode) {
      //   print("get logged in user api response $responseModel");
      // }

      loggedInUser = responseModel;

      return responseModel;
    }
    return null;
  }

  Future<AppUser?> getAppUser(String userId) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (FirebaseAuth.instance.currentUser != null &&
        userId != "" &&
        token != null) {
      if (kDebugMode) {
        print("Retrieving App Profile $userId");
      }
      final response = await http.get(
          Uri.parse("$authBaseUrl/get-profile/$userId"),
          headers: {"Authorization": ("Bearer $token")});

      dynamic processedResponse = jsonDecode(response.body);
      AppUser? responseModel;
      if (processedResponse['appProfile'] != null) {
        responseModel = AppUser.fromJson(processedResponse['appProfile']);
      }

      // if (kDebugMode) {
      //   print("get app user Auth api response $responseModel");
      // }
      return responseModel;
    }
    return null;
  }
}
