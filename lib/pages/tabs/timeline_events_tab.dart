import 'package:cookowt/layout/search_and_list.dart';
import 'package:flutter/material.dart';

import '../../models/controllers/auth_inherited.dart';
import '../../models/timeline_event.dart';
import '../../shared_components/timeline_events/timeline_event_thread.dart';

class TimelineEventsTab extends StatefulWidget {
  const TimelineEventsTab(
      {super.key,
      required this.timelineEvents,
      required this.id});

  final String id;
  final List<TimelineEvent>? timelineEvents;

  @override
  State<TimelineEventsTab> createState() => _TimelineEventsTabState();
}

class _TimelineEventsTabState extends State<TimelineEventsTab> {


  late List<TimelineEvent>? timelineEvents;

  @override
  void initState() {
    super.initState();

    timelineEvents = widget.timelineEvents;
  }

  @override
  didChangeDependencies() async {
    var theChatController = AuthInherited.of(context)?.chatController;
    timelineEvents = await theChatController?.updateTimelineEvents();
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAndList(
      listChild: TimelineEventThread(
        key: ObjectKey(timelineEvents),
        timelineEvents: timelineEvents ?? [],
      ),
    );
  }
}
