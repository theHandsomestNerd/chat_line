import 'package:kookout/models/hash_tag.dart';

import 'hash_tag.dart';

class HashtagCollection {
  String? id;
  String? name;
  String? description;
  List<Hashtag> theTags = <Hashtag>[];

  HashtagCollection.fromJson(Map<String, dynamic> json) {
    if (json['_id'] != null && json['_id'] != "null") {
      id = json["_id"];
    }
    if (json['name'] != null && json['name'] != "null") {
      name = json["name"];
    }
    if (json['description'] != null && json['description'] != "null") {
      description = json["description"];
    }
    if (json['theTags'] != null && json['theTags'] != "null") {
      theTags = convertTags(json['theTags']);
    }

  }

  convertTags(List<dynamic> parsedJson) {
    List<Hashtag> list = <Hashtag>[];

    list = parsedJson.map((i) => Hashtag.fromJson(i)).toList();

    return list;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['description'] = description;
    data['_id'] = id;
    data['theTags'] = theTags.toString();
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
