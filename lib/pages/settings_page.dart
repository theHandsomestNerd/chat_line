import 'package:cookowt/models/controllers/chat_controller.dart';
import 'package:cookowt/pages/tabs/blocks_tab.dart';
import 'package:cookowt/pages/tabs/edit_profile_tab.dart';
import 'package:cookowt/pages/tabs/timeline_events_tab.dart';
import 'package:cookowt/shared_components/menus/settings_menu.dart';
import 'package:cookowt/wrappers/app_scaffold_wrapper.dart';
import 'package:flutter/material.dart';

import '../models/block.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../models/controllers/auth_inherited.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  // final AuthController authController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;
  String myUserId = "";
  ChatController? chatController;
  AuthController? authController;
  List<Block>? myBlockedProfiles = [];
  AnalyticsController? analyticsController;

  @override
  void initState() {
    super.initState();
    // chatController?.updateProfiles();
    // chatController?.updateTimelineEvents();
  }

  @override
  didChangeDependencies() async {
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    theAnalyticsController?.logScreenView('settings');
    if (analyticsController == null && theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
    }
    ChatController? theChatController;
    if (chatController == null) {
      theChatController = AuthInherited.of(context)?.chatController;
      chatController = theChatController;
    }

    AuthController? theAuthController;
    if (authController == null) {
      theAuthController = AuthInherited.of(context)?.authController;
      authController = theAuthController;
    }

    if (myUserId == "") {
      myUserId = theAuthController?.myAppUser?.userId ?? "";
    }

    if (theChatController != null) {
      myBlockedProfiles = await theChatController.updateMyBlocks();
    }

    setState(() {});
    super.didChangeDependencies();
  }

  Widget _widgetOptions(selectedIndex) {
    var theOptions = <Widget>[
      EditProfileTab(analyticsController: analyticsController),
      TimelineEventsTab(
          timelineEvents: chatController?.timelineOfEvents,
          id: authController?.myAppUser?.userId ?? ""),
      BlocksTab(
        blocks: myBlockedProfiles ?? [],
        unblockProfile: (context) async {
          myBlockedProfiles = await chatController?.updateMyBlocks();
          setState(() {});
        },
      ),
    ];

    return theOptions.elementAt(selectedIndex);
  }

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        await analyticsController?.logScreenView('settings-edit-profile-tab');
        break;
      case 1:
        await analyticsController?.logScreenView('timeline-events-tab');
        break;
      case 2:
        await analyticsController?.logScreenView('blocks-tab');
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return AppScaffoldWrapper(
        floatingActionMenu: SettingsPageMenu(
          updateMenu: _onItemTapped,
        ),
        child: Stack(children: [
          Positioned.fill(
            child: Opacity(
              opacity: .1,
              child: Image.asset(
                'assets/img.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          ConstrainedBox(
            key: Key(_selectedIndex.toString()),
            constraints: const BoxConstraints(),
            child: _widgetOptions(
                _selectedIndex), // This trailing comma makes auto-formatting nicer for build methods.
          ),
        ]));
  }
}
