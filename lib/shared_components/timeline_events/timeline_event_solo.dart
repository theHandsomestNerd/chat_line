import 'package:kookout/models/timeline_event.dart';
import 'package:kookout/shared_components/user_block_text.dart';
import 'package:flutter/material.dart';

class TimelineEventSolo extends StatelessWidget {
  const TimelineEventSolo({
    super.key,
    required this.event,
  });

  final TimelineEvent event;

  getActionIcon(String action) {
    switch (action) {
      case "REGISTERED":
        return Icons.new_label;
      case "FOLLOWED":
        return Icons.arrow_right;
      case "UNFOLLOWED":
        return Icons.link_off;
      case "UNLIKED":
        return Icons.thumb_down;
      case "LIKED":
        return Icons.thumb_up;
      case "COMMENTED":
        return Icons.comment;
      case "POSTED":
        return Icons.post_add;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: UserBlockText(user: event.actor)),
          Expanded(
            flex: 3,
            child: Center(
              child: Icon(
                getActionIcon(event.action ?? ""),
                size: 24.0,
                semanticLabel: 'Likes',
              ),
            ),
          ),
          Expanded(flex: 1, child: UserBlockText(user: event.recipient)),
        ],
      ),
    );
  }
}
