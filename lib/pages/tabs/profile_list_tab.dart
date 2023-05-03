import 'package:cookowt/layout/search_and_list.dart';
import 'package:flutter/material.dart';

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
