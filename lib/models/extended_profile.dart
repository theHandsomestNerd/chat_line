
import 'package:cookout/models/app_user.dart';

import 'submodels/height.dart';

class ExtendedProfile {
  int? age;
  int? weight;

  Height? height;

  String? shortBio;
  String? longBio;
  String? userId;
  String? gender;
  String? facebook;
  String? twitter;
  String? instagram;
  String? partnerStatus;
  String? ethnicity;
  String? iAm;
  String? imInto;
  String? imOpenTo;
  String? whatIDo;
  String? whatImLookingFor;
  String? whatInterestsMe;
  String? whereILive;
  String? sexPreferences;
  bool? nsfwFriendly;
  bool? isTraveling;
  String? hivStatus;
  DateTime? lastTested;
  List<String>? pronouns = [];
  List<String>? hashtags = [];

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

  ExtendedProfile({
    this.age,
    this.height,
    this.weight,
    this.shortBio,
    this.longBio,
    this.userId,
    this.gender,
    this.facebook,
    this.twitter,
    this.instagram,
    this.partnerStatus,
    this.ethnicity,
    this.iAm,
    this.imInto,
    this.sexPreferences,
    this.imOpenTo,
    this.whatIDo,
    this.whatImLookingFor,
    this.whatInterestsMe,
    this.whereILive,
    this.isTraveling,
    this.lastTested,
    this.pronouns,
    this.hashtags,
    this.userRef
  }) {
    age = age;
    weight = weight;
    height = height;
    shortBio = shortBio;
    longBio = longBio;
    userId = userId;
    gender = gender;
    facebook = facebook;
    twitter = twitter;
    instagram = instagram;
    partnerStatus = partnerStatus;
    ethnicity = ethnicity;
    iAm = iAm;
    imInto = imInto;
    imOpenTo = imOpenTo;
    whatIDo = whatIDo;
    whatImLookingFor = whatImLookingFor;
    whatInterestsMe = whatInterestsMe;
    whereILive = whereILive;
    sexPreferences = sexPreferences;
    // isTraveling = isT;
    // lastTested = DateTime.now();
    pronouns = pronouns;
    hashtags = hashtags;
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
    if(json["height"] != null && json["height"] != "null") {
      height = Height.fromJson(json['height']);
    }
    if(json["userRef"] != null && json["userRef"] != "null") {
      userRef = AppUser.fromJson(json['userRef']);
    }
    shortBio = json['shortBio'];
    longBio = json['longBio'];
    userId = json['userId'];
    gender = json['gender'];
    facebook = json['facebook'];
    twitter = json['twitter'];
    instagram = json['instagram'];
    partnerStatus = json['partnerStatus'];
    ethnicity = json['ethnicity'];
    iAm = json['iAm'];
    imInto = json['imInto'];
    imOpenTo = json['imOpenTo'];
    whatIDo = json['whatIDo'];
    whatImLookingFor = json['whatImLookingFor'];
    whatInterestsMe = json['whatInterestsMe'];
    whereILive = json['whereILive'];
    sexPreferences = json['sexPreferences'];
    // nsfwFriendly = json['nsfwFriendly'] as bool?;
    // isTraveling=json['isTraveling'] as bool?;
    // lastTested = DateTime(json['lastTested']);
    // pronouns = processJsonStringArr(json['pronouns']);
    // hashtags = processJsonStringArr(json['hashtags']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['age'] = age;
    data['weight'] = weight;
    data['shortBio'] = shortBio;
    data['longBio'] = longBio;
    data['userId'] = userId;
    data['userRef'] = userRef;
    data['gender'] = gender;
    data['facebook'] = facebook;
    data['twitter'] = twitter;
    data['instagram'] = instagram;
    // data['height'] = height;
    data['partnerStatus'] = partnerStatus;
    data['ethnicity'] = ethnicity;
    data['iAm'] = iAm;
    data['imInto'] = imInto;
    data['imOpenTo'] = imOpenTo;
    data['whatIDo'] = whatIDo;
    data['whatImLookingFor'] = whatImLookingFor;
    data['whatInterestsMe'] = whatInterestsMe;
    data['whereILive'] = whereILive;
    data['sexPreferences'] = sexPreferences;
    data['isTraveling'] = isTraveling;
    data['nsfwFriendly'] = nsfwFriendly;
    data['lastTested'] = lastTested;
    data['pronouns'] = pronouns;
    data['hashtags'] = hashtags;
    return data;
  }

  @override
  String toString() {
    return '\n__________Extended Profile_______________\n'
        '\nage:$age '
        '\nweight:$weight '
        '\nheight:${height?.feet} ${height?.inches} '
        '\nshortBio:$shortBio '
        '\nlongBio:$longBio '
        '\nuserId:$userId '
        '\ngender:$gender '
        '\nfacebook:$facebook '
        '\ntwitter:$twitter '
        '\ninstagram:$instagram '
        '\npartnerStatus:$partnerStatus '
        '\nethnicity:$ethnicity '
        '\nIam:$iAm '
        '\nIminto:$imInto '
        '\nimopento:$imOpenTo '
        '\nwhatIdo:$whatIDo '
        '\nwhatimlookingfor:$whatImLookingFor '
        '\nwhatinterestsme:$whatInterestsMe '
        '\nsexPreferences:$sexPreferences '
        '\nwhereIlive:$whereILive '
        '\nisTraveling:$isTraveling '
        '\nlasttested:$lastTested '
        '\npronouns:$pronouns '
        '\nhashtags:$hashtags '
        '\n-----------------------------\n';
  }
}
