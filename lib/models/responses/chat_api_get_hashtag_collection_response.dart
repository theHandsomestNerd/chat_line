

import 'package:flutter/foundation.dart';

import '../post.dart';

class ChatApiGetHashtagCollectionResponse {
  final List<Post> list;

  ChatApiGetHashtagCollectionResponse({
    required this.list,
  });

  factory ChatApiGetHashtagCollectionResponse.fromJson(List<dynamic> parsedJson) {
    List<Post> list = <Post>[];

    // if (kDebugMode) {
    //   print("get-posts-response $parsedJson");
    // }

    list = parsedJson.map((i) => Post.fromJson(i)).toList();

    return ChatApiGetHashtagCollectionResponse(list: list);
  }
}
