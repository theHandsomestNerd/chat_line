import 'package:kookout/layout/search_and_list.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/follow.dart';
import '../../shared_components/follows/follows_thread.dart';

class FollowsTab extends StatelessWidget {
  const FollowsTab(
      {super.key,
      required this.thisProfile,
      required this.isThisMe,
      required this.profileFollowedByMe,
      required this.profileFollows,
      required this.id});

  final AppUser? thisProfile;
  final String id;
  final bool isThisMe;
  final List<Follow>? profileFollows;
  final Follow? profileFollowedByMe;

  @override
  Widget build(BuildContext context) {
    return SearchAndList(
      listChild: FollowThread(
        key: ObjectKey(profileFollows),
        follows: profileFollows ?? [],
      ),
    );
  }
}
