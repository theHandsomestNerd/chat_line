import 'package:chat_line/models/timeline_event.dart';
import 'package:flutter/foundation.dart';

class ChatApiGetTimelineEventsResponse {
  final List<TimelineEvent> list;

  ChatApiGetTimelineEventsResponse({
    required this.list,
  });

  factory ChatApiGetTimelineEventsResponse.fromJson(List<dynamic> parsedJson) {
    List<TimelineEvent> list = <TimelineEvent>[];

    // if (kDebugMode) {
    //   print("get-timeline-events-response $parsedJson");
    // }

    list = parsedJson.map((i) => TimelineEvent.fromJson(i)).toList();

    return ChatApiGetTimelineEventsResponse(list: list);
  }
}