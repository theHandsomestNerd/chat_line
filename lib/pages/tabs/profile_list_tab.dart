import 'package:cookout/layout/search_and_list.dart';
import 'package:cookout/models/controllers/chat_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/controllers/auth_inherited.dart';
import '../../shared_components/profile/profile_grid.dart';

class ProfileListTab extends StatefulWidget {
  const ProfileListTab({
    super.key,
  });

  @override
  State<ProfileListTab> createState() => _ProfileListTabState();
}

class _ProfileListTabState extends State<ProfileListTab> {
  late List<AppUser> profileList = [];
  late ChatController? chatController = null;

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theChatController = AuthInherited.of(context)?.chatController;
    chatController = theChatController;
    var theProfiles = await chatController?.updateProfiles();
    profileList = theProfiles;
    setState(() {});
    if (kDebugMode) {
      print("dependencies changed profile list ${profileList.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchAndList(
      isSearchEnabled: true,
      listChild: ProfileGrid(
        profiles: profileList,
      ),
    );
  }
}
