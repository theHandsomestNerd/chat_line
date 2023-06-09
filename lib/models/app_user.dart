import 'package:flutter/foundation.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';

class AppUser {
  String email = "";
  String? displayName;
  String? userId;
  SanityImage? profileImage;

  // LoginProvider? loginProvider;

  AppUser.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      userId = json['_id'];
    }
    if (json['email'] != null) {
      email = json['email'];
    }
    if (json['displayName'] != null) {
      displayName = json['displayName'];
    }
    if (json['userId'] != null) {
      userId = json['userId'];
    }

    if (json['profileImage'] != null) {
      try {
        profileImage = SanityImage.fromJson(json['profileImage']);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['1'] = displayName;
    data['2'] = email;
    data['3'] = userId;
    data['4'] = profileImage;
    // data['5'] = loginProvider;
    return data;
  }

// @override
// String toString() {
//   return '\n_______________App User____________\n'
//       '\nname:$displayName '
//       '\nemail:$email '
//       '\nuserId:$userId '
//       '\nprofileImage:${profileImage?.toString()} '
//       '\n-----------------------------\n';
// }
}
