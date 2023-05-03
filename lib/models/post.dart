import 'package:kookout/models/sanity/document_slug.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';

import 'app_user.dart';

class Post {

  String? id;
  AppUser? author;
  String? title;
  String? body;
  DateTime? publishedAt;
  DocumentSlug? slug;

  SanityImage? mainImage;

  // categories: SanityCategory[],

  @override
  Post.fromJson(Map<String, dynamic> json) {
    if (json['_id'] != null && json['_id'] != "null") {
      id = json["_id"];
    }
    if (json['author'] != null && json['author'] != "null") {
      author = AppUser.fromJson(json["author"]);
    }
    if (json['title'] != null && json['title'] != "null") {
      title = json["title"];
    }
    if (json['body'] != null && json['body'] != "null") {
      body = json["body"];
    }
    if (json['publishedAt'] != null && json['publishedAt'] != "null") {
      publishedAt = DateTime.parse(json["publishedAt"].toString());
    }
    if (json['slug'] != null && json['slug'] != "null") {
      slug = DocumentSlug.fromJson(json["slug"]);
    }
    if (json['mainImage'] != null) {
      try {
        mainImage = SanityImage.fromJson(json['mainImage']);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['author'] = author?.toJson();
    data['author'] = slug?.toJson();
    data['title'] = title;
    data['body'] = body;
    data['publishedAt'] = publishedAt;
    return data;
  }

// @override
// toString(){
//   return '\n______________Post:${id}______________\n'
//       '\nauthor:${author?.userId} '
//       '\nrecipient:${recipient?.userId} '
//       '\ncommentBody:$commentBody '
//       '\npublishedAt:${publishedAt.toString()} '
//       '\n-----------------------------\n';
// }
}
