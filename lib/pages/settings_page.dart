import 'package:chat_line/models/app_user.dart';
import 'package:chat_line/models/controllers/chat_controller.dart';
import 'package:chat_line/pages/tabs/blocks_tab.dart';
import 'package:chat_line/pages/tabs/edit_profile_tab.dart';
import 'package:chat_line/pages/tabs/posts_tab.dart';
import 'package:chat_line/pages/tabs/profile_list_tab.dart';
import 'package:chat_line/pages/tabs/timeline_events_tab.dart';
import 'package:chat_line/shared_components/menus/profile_page_menu.dart';
import 'package:chat_line/shared_components/menus/settings_menu.dart';
import 'package:flutter/material.dart';

import '../models/block.dart';
import '../models/controllers/auth_inherited.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key,});

  // final AuthController authController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;
  String myUserId = "";
  late ChatController? chatController = null;
  late List<Block>? myBlockedProfiles = [];

  @override
  void initState() {
    super.initState();
    // chatController?.updateProfiles();
    // chatController?.updateTimelineEvents();
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theChatController = AuthInherited.of(context)?.chatController;
    chatController = theChatController;
    myUserId = AuthInherited.of(context)?.authController?.myAppUser?.userId ?? "";
    myBlockedProfiles = await chatController?.updateMyBlocks();
    setState(() {});
    print("dependencies changed $myUserId");
  }

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  Widget _widgetOptions(selectedIndex) {
    var theOptions = <Widget>[
      EditProfileTab(),
      TimelineEventsTab(
          timelineEvents: chatController?.timelineOfEvents,
          id: AuthInherited.of(context)?.authController?.myAppUser?.userId ??
              ""),
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

  void _onItemTapped(int index) {
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

    return Scaffold(
      floatingActionButton: SettingsPageMenu(
        updateMenu: _onItemTapped,
      ),
      appBar: AppBar(
        // Here we take the value from the LoggedInHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Chat Line - Settings"),
      ),
      body: ConstrainedBox(
          key: Key(_selectedIndex.toString()),
          constraints: const BoxConstraints(),
          child: _widgetOptions(
              _selectedIndex)), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}