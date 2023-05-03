import 'package:cookowt/shared_components/user_block_text.dart';
import 'package:flutter/material.dart';

import '../../models/follow.dart';

class FollowSolo extends StatelessWidget {
  const FollowSolo({
    super.key,
    required this.follow,
  });

  final Follow follow;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: UserBlockText(user: follow.follower)),
          const Expanded(
            flex: 3,
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_right_rounded,
                size: 24.0,
                semanticLabel: 'Edit Profile',
              ),
            ),
          ),
          Expanded(flex: 1, child: UserBlockText(user: follow.followed)),
        ],
      ),
    );
  }
}
