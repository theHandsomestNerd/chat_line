import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../config/default_config.dart';
import '../app_user.dart';
import '../block.dart';
import '../comment.dart';
import '../extended_profile.dart';
import '../follow.dart';
import '../like.dart';
import '../responses/auth_api_profile_list_response.dart';
import '../responses/chat_api_get_profile_block_response.dart';
import '../responses/chat_api_get_profile_comments_response.dart';
import '../responses/chat_api_get_profile_follows_response.dart';
import '../responses/chat_api_get_profile_likes_response.dart';
import '../responses/chat_api_get_timeline_events_response.dart';
import '../timeline_event.dart';

class BugReportClient {
  String token = "";

  BugReportClient() {
    FirebaseAuth.instance.currentUser?.getIdToken().then((theToken) {
      token = theToken;
    });
  }

  Future<String?> getIdToken() async {
    if (token != "") {
      print("Using cached Id Token");
      return token;
    } else {
      print("Retrieving Id Token");
      String? theToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (theToken != null) {
        token = theToken;
        return theToken;
      }
    }
  }

  Future<void> submitBugReport(String title, String description,
      String filename, fileBytes, BuildContext context) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (DefaultConfig.theAuthBaseUrl != null) {
      var request = http.MultipartRequest('POST',
          Uri.parse("${DefaultConfig.theAuthBaseUrl}/submit-bug-report"));

      request.headers.addAll({"authorization": "Bearer $token"});

      if (filename != "") {
        request.files.add(http.MultipartFile.fromBytes('file', fileBytes,
            contentType: MediaType('application', 'octet-stream'),
            filename: filename));
      }

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['uiVersion'] = DefaultConfig.theVersion+"."+DefaultConfig.thebuildNumber;
      request.fields['apiVersion'] = DefaultConfig.theApiVersion;
      request.fields['uiSanityDB'] = DefaultConfig.theSanityDB;
      request.fields['apiSanityDB'] = DefaultConfig.theApiDb;
      print("Before bug submission ui Version ${DefaultConfig.theVersion}");
      print("Before bug submission api version${DefaultConfig.theApiVersion}");
      print("Before bug submission ui db${DefaultConfig.theSanityDB}");
      print("Before bug submission api db ${DefaultConfig.theApiDb}");

      await request.send();
      return;
    }
  }
}
