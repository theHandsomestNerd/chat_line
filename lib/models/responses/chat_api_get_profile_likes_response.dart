import 'package:chat_line/models/like.dart';
import 'package:flutter/foundation.dart';

class ChatApiGetProfileLikesResponse {
  final List<Like> list;
  final Like? amIInThisList;

  ChatApiGetProfileLikesResponse({required this.list, this.amIInThisList,});

  factory ChatApiGetProfileLikesResponse.fromJson(Map<String, dynamic> json) {
    getListOfLikes(List<dynamic> parsedJson) {
      if(parsedJson != null) {
        return parsedJson.map((i) => Like.fromJson(i)).toList();
      }
      return <Like>[];
    }

    List<Like> theList = <Like>[];
    Like? amIInThisList=null;

    if (kDebugMode) {
      print("get-likes-response $json");
    }
    theList = getListOfLikes(json['profileLikes']);

    if (json['amIInThisList'] != null && json['amIInThisList'] != "null") {
      amIInThisList = Like.fromJson(json['amIInThisList']);
    }

    return ChatApiGetProfileLikesResponse(
        list: theList, amIInThisList: amIInThisList);
  }
}