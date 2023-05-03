import 'package:cookowt/models/comment.dart';
import 'package:cookowt/models/like.dart';
import 'package:cookowt/models/post.dart';
import 'package:flutter/foundation.dart';

import 'app_user.dart';
import 'follow.dart';


class CmsDocument {
  String? type;

  CmsDocument.fromJson(Map<String, dynamic> json) {
    if (json['_type'] != null && json['_type'] != "null") {
      if (kDebugMode) {
        // print("processing type of this thing ${json['_type']}");
      }
      type = json["_type"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_type'] = type;
    return data;
  }

  @override
  toString(){
    return '\n______________CmsDocument:______________\n'
        '\n type:$type '
        '\n-----------------------------\n';
  }
}

class TimelineEvent {
  bool? isPublic;
  AppUser? actor;
  String? action;
  AppUser? recipient;
  String? id;
  dynamic item;

  TimelineEvent.fromJson(Map<String, dynamic> json) {
    if (json['_id'] != null && json['_id'] != "null") {
      id = json["_id"];
    }
    if (json['actor'] != null && json['actor'] != "null") {
      actor = AppUser.fromJson(json["actor"]);
    }

    if (json['action'] != null && json['action'] != "null") {
      action = json["action"];
    }

    if (json['recipient'] != null && json['recipient'] != "null") {
      recipient = AppUser.fromJson(json["recipient"]);
    }

    if (json['item'] != null && json['item'] != "null") {
      var theItem = CmsDocument.fromJson(json["item"]);

      switch(theItem.type){
        case "Follow":
          item = Follow.fromJson(json["item"]);
          break;
        case "Like":
          item = Like.fromJson(json["item"]);
          break;
        case "Comment":
          item = Comment.fromJson(json["item"]);
          break;
        case "user":
          item = AppUser.fromJson(json["item"]);
          break;
        case "Post":
          item = Post.fromJson(json["item"]);
          break;
      }

    }


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isPublic'] = isPublic;
    data['actor'] = actor?.toJson();
    data['recipient'] = recipient?.toJson();
    data['action'] = action;
    data['item'] = item?.toJson();
    data['_id'] = id;
    return data;
  }

  // @override
  // toString(){
  //   return '\n______________TimelineEvent:${id}______________\n'
  //       '\n actor:${isPublic} '
  //       '\n actor:${actor?.userId} '
  //       '\n action:${action} '
  //       '\n recipient:${recipient?.userId} '
  //       '\n item:${item} '
  //       '\n-----------------------------\n';
  // }
}
