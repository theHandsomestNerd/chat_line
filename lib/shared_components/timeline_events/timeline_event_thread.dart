import 'package:cookowt/shared_components/timeline_events/timeline_event_solo.dart';
import 'package:flutter/material.dart';

import '../../models/timeline_event.dart';

class TimelineEventThread extends StatelessWidget {
  const TimelineEventThread({
    super.key,
    required this.timelineEvents,
  });

  final List<TimelineEvent>? timelineEvents;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...timelineEvents != null ?(timelineEvents!).map((event) {
          return Column(
            children: [TimelineEventSolo(event: event), const Divider()],
          );
        }).toList():[]
      ],
    );
  }
}
