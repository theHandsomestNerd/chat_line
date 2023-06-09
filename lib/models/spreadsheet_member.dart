class SpreadsheetMember {
  String? id;
  String? spreadsheetId;
  bool? isAutoGenerated;
  bool? isChapterInvisible;
  bool? isOnTheYard;
  bool? isLivesOnCampus;
  String? onCampusPosition;
  String? firstName;
  String? middleName;
  String? lastName;
  String? nickName;
  String? title;
  List<String>? email;
  String? cellPhone;
  String? homePhone;
  String? workPhone;
  String? semester;
  String? otherChapterAffiliation;
  DateTime? crossingDate;
  String? year;
  String? nameOfLine;
  String? lineName;
  String? lineNumber;
  String? dopName;
  String? address;
  String? city;
  String? postalCode;
  String? state;
  String? occupation;
  String? spouse;
  List<String>? children;
  DateTime? dob;

  SpreadsheetMember.fromJson(Map<String, dynamic> json) {
    if (json['_id'] != null && json['_id'] != "null") {
      id = json["_id"];
    }
    if (json['spreadsheetId'] != null && json['spreadsheetId'] != "null") {
      spreadsheetId = json["spreadsheetId"];
    }
    if (json['isAutoGenerated'] != null && json['isAutoGenerated'] != "null") {
      isAutoGenerated = json["isAutoGenerated"];
    }
    if (json['isChapterInvisible'] != null && json['isChapterInvisible'] != "null") {
      isChapterInvisible = json["isChapterInvisible"];
    }
    if (json['isOnTheYard'] != null && json['isOnTheYard'] != "null") {
      isOnTheYard = json["isOnTheYard"];
    }
    if (json['isLivesOnCampus'] != null && json['isLivesOnCampus'] != "null") {
      isLivesOnCampus = json["isLivesOnCampus"];
    }
    if (json['onCampusPosition'] != null && json['onCampusPosition'] != "null") {
      onCampusPosition = json["onCampusPosition"];
    }
    if (json['firstName'] != null && json['firstName'] != "null") {
      firstName = json["firstName"];
    }
    if (json['middleName'] != null && json['middleName'] != "null") {
      middleName = json["middleName"];
    }
    if (json['lastName'] != null && json['lastName'] != "null") {
      lastName = json["lastName"];
    }
    if (json['nickName'] != null && json['nickName'] != "null") {
      nickName = json["nickName"];
    }
    if (json['title'] != null && json['title'] != "null") {
      title = json["title"];
    }
    if (json['email'] != null && json['email'] != "null") {
      email = (json['email'] as List).map((item) => item as String).toList();
    }
    if (json['cellPhone'] != null && json['cellPhone'] != "null") {
      cellPhone = json["cellPhone"];
    }
    if (json['homePhone'] != null && json['homePhone'] != "null") {
      homePhone = json["homePhone"];
    }
    if (json['workPhone'] != null && json['workPhone'] != "null") {
      workPhone = json["workPhone"];
    }
    if (json['semester'] != null && json['semester'] != "null") {
      semester = json["semester"];
    }
    if (json['otherChapterAffiliation'] != null && json['otherChapterAffiliation'] != "null") {
      otherChapterAffiliation = json["otherChapterAffiliation"];
    }
    if (json['crossingDate'] != null && json['crossingDate'] != "null") {
      crossingDate = DateTime.parse(json["crossingDate"]);
    }
    if (json['year'] != null && json['year'] != "null") {
      year = json["year"];
    }
    if (json['nameOfLine'] != null && json['nameOfLine'] != "null") {
      nameOfLine = json["nameOfLine"];
    }
    if (json['lineName'] != null && json['lineName'] != "null") {
      lineName = json["lineName"];
    }
    if (json['lineNumber'] != null && json['lineNumber'] != "null") {
      lineNumber = json["lineNumber"];
    }
    if (json['dopName'] != null && json['dopName'] != "null") {
      dopName = json["dopName"];
    }
    if (json['address'] != null && json['address'] != "null") {
      address = json["address"];
    }
    if (json['city'] != null && json['city'] != "null") {
      city = json["city"];
    }
    if (json['postalCode'] != null && json['postalCode'] != "null") {
      postalCode = json["postalCode"];
    }
    if (json['state'] != null && json['state'] != "null") {
      state = json["state"];
    }
    if (json['occupation'] != null && json['occupation'] != "null") {
      occupation = json["occupation"];
    }
    if (json['spouse'] != null && json['spouse'] != "null") {
      spouse = json["spouse"];
    }
    if (json['children'] != null && json['children'] != "null") {
      children = (json['children'] as List).map((item) => item as String).toList();
    }
    if (json['dob'] != null && json['dob'] != "null") {
      dob = DateTime.parse(json["dob"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['tag'] = tag;
    // data['start'] = start;
    // data['_id'] = id;
    // data['end'] = end;
    return data;
  }

// @override
// toString(){
//   return '\n______________Hashtag
//   :${id}______________\n'
//       '\nliker:${liker?.userId} '
//       '\nlikee:${likee?.userId} '
//       '\nlikeCategory:$likeCategory '
//       '\n-----------------------------\n';
// }
}
