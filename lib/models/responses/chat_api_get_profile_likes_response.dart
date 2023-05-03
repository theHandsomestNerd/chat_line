import 'package:cookowt/models/like.dart';

class ChatApiGetProfileLikesResponse {
  final List<Like> list;
  final Like? amIInThisList;

  ChatApiGetProfileLikesResponse({required this.list, this.amIInThisList,});

  factory ChatApiGetProfileLikesResponse.fromJson(Map<String, dynamic> json) {
    getListOfLikes(List<dynamic> parsedJson) {
      return parsedJson.map((i) => Like.fromJson(i)).toList();
    }

    List<Like> theList = <Like>[];
    Like? amIInThisList;

    // if (kDebugMode) {
    //   print("get-likes-response $json");
    // }
    theList = getListOfLikes(json['profileLikes']);

    if (json['amIInThisList'] != null && json['amIInThisList'] != "null") {
      amIInThisList = Like.fromJson(json['amIInThisList']);
    }

    return ChatApiGetProfileLikesResponse(
        list: theList, amIInThisList: amIInThisList);
  }
}
