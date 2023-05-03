import 'package:cookowt/models/app_user.dart';
import 'package:flutter/foundation.dart';

class AuthApiProfileListResponse {
  final List<AppUser> list;

  AuthApiProfileListResponse({
    required this.list,
  });

  factory AuthApiProfileListResponse.fromJson(List<dynamic> parsedJson) {
    List<AppUser> list = <AppUser>[];

    if (kDebugMode) {
      // print("authlistofprofilesresponse ${parsedJson}");
    }

    list = parsedJson.map((i) => AppUser.fromJson(i)).toList();

    return AuthApiProfileListResponse(list: list);
  }
}
