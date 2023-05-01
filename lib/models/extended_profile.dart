import 'dart:convert';

import 'package:kookout/models/app_user.dart';

import 'submodels/height.dart';

class ExtendedProfile {
  int? age;
  int? weight;
  Height? height;
  String? shortBio;
  String? longBio;
  String? userId;
  String? homeNumber;
  String? workNumber;
  String? cellNumber;
  String? facebook;
  String? twitter;
  String? instagram;
  String? tiktok;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? zip;
  String? govtIssuedFirstName;
  String? govtIssuedMiddleName;
  String? govtIssuedLastName;
  String? otherChapterAffiliation;
  String? dopName;
  String? lineName;
  String? lineNumber;
  String? entireLinesName;
  DateTime? dob;
  DateTime? crossingDate;
  String? occupation;
  String? ethnicity;
  List<String>? children = [];
  AppUser? userRef;

  processJsonStringArr(pronounsJson) {
    List<dynamic> pronounList = pronounsJson ?? [];

    List<String> pronounListStr = <String>[];

    for (var element in pronounList) {
      var elementInQuestion = element;

      pronounListStr.add(elementInQuestion);
    }

    return pronounListStr;
  }

  ExtendedProfile(
      {this.age,
      this.height,
      this.weight,
      this.shortBio,
      this.longBio,
      this.userId,
      this.facebook,
      this.twitter,
      this.instagram,
      this.tiktok,
      this.homeNumber,
      this.workNumber,
      this.cellNumber,
      this.ethnicity,
      this.occupation,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.zip,
      this.lineName,
      this.lineNumber,
      this.dopName,
      this.entireLinesName,
      this.otherChapterAffiliation,
      this.crossingDate,
      this.dob,
      this.children,
      this.userRef}) {
    age = age;
    height = height;
    weight = weight;
    shortBio = shortBio;
    longBio = longBio;
    userId = userId;
    facebook = facebook;
    twitter = twitter;
    instagram = instagram;
    tiktok = tiktok;
    homeNumber = homeNumber;
    workNumber = workNumber;
    cellNumber = cellNumber;
    ethnicity = ethnicity;
    occupation = occupation;
    address1 = address1;
    address2 = address2;
    city = city;
    state = state;
    zip = zip;
    lineName = lineName;
    lineNumber = lineNumber;
    dopName = dopName;
    entireLinesName = entireLinesName;
    otherChapterAffiliation = otherChapterAffiliation;
    crossingDate = crossingDate;
    dob = dob;
    children = children;
    userRef = userRef;
  }

  ExtendedProfile.fromJson(Map<String, dynamic> json) {
    if (json['age'] != null && json['age'] != "null") {
      if (json['age'] is String) {
        age = double.parse(json["age"]) as int;
      }
      if (json['age'] is int) {
        age = json["age"];
      }
    }
    if (json['weight'] != null && json['weight'] != "null") {
      if (json['weight'] is String) {
        weight = double.parse(json["weight"]) as int;
      }
      if (json['weight'] is int) {
        weight = json["weight"];
      }
    }
    if (json["height"] != null && json["height"] != "null") {
      height = Height.fromJson(json['height']);
    }
    if (json["userRef"] != null && json["userRef"] != "null") {
      userRef = AppUser.fromJson(json['userRef']);
    }

    shortBio = json['shortBio'];
    longBio = json['longBio'];
    userId = json['userId'];
    facebook = json['facebook'];
    twitter = json['twitter'];
    instagram = json['instagram'];
    tiktok = json['tiktok'];
    homeNumber = json['homeNumber'];
    workNumber = json['workNumber'];
    cellNumber = json['cellNumber'];
    ethnicity = json['ethnicity'];
    occupation = json['occupation'];
    address1 = json['address1'];
    address2 = json['address2'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    lineName = json['lineName'];
    dopName = json['dopName'];
    entireLinesName = json['entireLinesName'];
    lineName = json['lineName'];
    otherChapterAffiliation = json['otherChapterAffiliation'];
    crossingDate = json['crossingDate'];
    dob = json['dob'];
    children = json['children'];
    userRef = json['userRef'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['age'] = age;
    data['weight'] = weight;
    data['shortBio'] = shortBio;
    data['longBio'] = longBio;
    data['userId'] = userId;
    data['userRef'] = userRef;
    data['facebook'] = facebook;
    data['twitter'] = twitter;
    data['instagram'] = instagram;
    // data['height'] = height;
    data['ethnicity'] = ethnicity;
    data['height'] = height;
    data['weight'] = weight;
    data['shortBio'] = shortBio;
    data['longBio'] = longBio;
    data['userId'] = userId;
    data['facebook'] = facebook;
    data['twitter'] = twitter;
    data['instagram'] = instagram;
    data['tiktok'] = tiktok;
    data['homeNumber'] = homeNumber;
    data['workNumber'] = workNumber;
    data['cellNumber'] = cellNumber;
    data['ethnicity'] = ethnicity;
    data['occupation'] = occupation;
    data['address1'] = address1;
    data['address2'] = address2;
    data['city'] = city;
    data['state'] = state;
    data['zip'] = zip;
    data['lineName'] = lineName;
    data['lineNumber'] = lineNumber;
    data['dopName'] = dopName;
    data['entireLinesName'] = entireLinesName;
    data['otherChapterAffiliation'] = otherChapterAffiliation;
    data['crossingDate'] = crossingDate;
    data['dob'] = dob;
    data['children'] = jsonEncode(children);
    data['userRef'] = userRef;
    return data;
  }

// @override
// String toString() {
//   return '\n__________Extended Profile_______________\n'
//       '\nage:$age '
//       '\nweight:$weight '
//       '\nheight:${height?.feet} ${height?.inches} '
//       '\nshortBio:$shortBio '
//       '\nlongBio:$longBio '
//       '\nuserId:$userId '
//       '\ngender:$gender '
//       '\nfacebook:$facebook '
//       '\ntwitter:$twitter '
//       '\ninstagram:$instagram '
//       '\npartnerStatus:$partnerStatus '
//       '\nethnicity:$ethnicity '
//       '\nIam:$iAm '
//       '\nIminto:$imInto '
//       '\nimopento:$imOpenTo '
//       '\nwhatIdo:$whatIDo '
//       '\nwhatimlookingfor:$whatImLookingFor '
//       '\nwhatinterestsme:$whatInterestsMe '
//       '\nsexPreferences:$sexPreferences '
//       '\nwhereIlive:$whereILive '
//       '\nisTraveling:$isTraveling '
//       '\nlasttested:$lastTested '
//       '\npronouns:$pronouns '
//       '\nhashtags:$hashtags '
//       '\n-----------------------------\n';
// }
}
