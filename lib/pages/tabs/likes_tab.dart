import 'package:cookowt/layout/search_and_list.dart';
import 'package:cookowt/shared_components/likes/likes_thread.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/like.dart';

class LikesTab extends StatelessWidget {
  const LikesTab(
      {super.key,
      required this.thisProfile,
      required this.isThisMe,
      required this.profileLikedByMe,
      required this.profileLikes,
      required this.id});

  final AppUser? thisProfile;
  final String id;
  final bool isThisMe;
  final List<Like>? profileLikes;
  final Like? profileLikedByMe;

  @override
  Widget build(BuildContext context) {
    return SearchAndList(
      listChild: LikeThread(
        key: ObjectKey(profileLikes),
        likes: profileLikes ?? [],
      ),
    );
  }
}
