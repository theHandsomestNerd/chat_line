import 'package:cookout/layout/search_and_list.dart';
import 'package:cookout/models/controllers/chat_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/controllers/auth_inherited.dart';
import '../../shared_components/profile/profile_grid.dart';

class ProfileListTab extends StatelessWidget {
  const ProfileListTab({
    super.key,
  });

  // late List<AppUser> profileList = [];
  @override
  Widget build(BuildContext context) {
    return const SearchAndList(
      isSearchEnabled: true,
      listChild: ProfileGrid(),
    );
  }
}
