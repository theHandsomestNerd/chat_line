import 'package:cookout/models/controllers/chat_controller.dart';
import 'package:cookout/pages/tabs/blocks_tab.dart';
import 'package:cookout/pages/tabs/posts_tab.dart';
import 'package:cookout/pages/tabs/profile_list_tab.dart';
import 'package:cookout/pages/tabs/timeline_events_tab.dart';
import 'package:cookout/shared_components/menus/profile_page_menu.dart';
import 'package:flutter/material.dart';

import '../models/block.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../shared_components/logo.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({
    super.key,
  });

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  int _selectedIndex = 0;
  String myUserId = "";
  late AnalyticsController? analyticsController=null;

  late AuthController? authController = null;
  late ChatController? chatController = null;
  late List<Block>? myBlockedProfiles = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theChatController = AuthInherited.of(context)?.chatController;
    var theAuthController = AuthInherited.of(context)?.authController;
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    if(analyticsController == null && theAnalyticsController != null) {
    await theAnalyticsController.logScreenView('profiles-page');
      analyticsController = theAnalyticsController;
    }
    if(authController == null && theAuthController != null) {
      authController = authController;
    }
    chatController = theChatController;
    myUserId =
        AuthInherited.of(context)?.authController?.myAppUser?.userId ?? "";
    myBlockedProfiles = await chatController?.updateMyBlocks();
    setState(() {});
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  Widget _widgetOptions(selectedIndex) {
    var theOptions = <Widget>[
      ProfileListTab(),
      TimelineEventsTab(
          timelineEvents: chatController?.timelineOfEvents,
          id: authController?.myAppUser?.userId ??
              ""),
      const Text(
        'Index 3: Likes and Follows',
        style: optionStyle,
      ),
      BlocksTab(
        blocks: myBlockedProfiles ?? [],
        unblockProfile: (context) async {
          await analyticsController?.sendAnalyticsEvent('profile-unblock',{"unblocker": authController?.myAppUser?.userId});

          myBlockedProfiles = await chatController?.updateMyBlocks();
          setState(() {});
        },
      ),
      const Text(
        'Index 4: Albums',
        style: optionStyle,
      ),
      const PostsTab(),
    ];

    return theOptions.elementAt(selectedIndex);
  }

  void _onItemTapped(int index)async {
    switch (index) {
      case 0:
        await analyticsController?.logScreenView('profiles-tab');
        break;
      case 1:
        await analyticsController?.logScreenView('timeline-events-tab');
        break;
      case 3:
        await analyticsController?.logScreenView('blocks-tab');
        break;
      case 5:
        await analyticsController?.logScreenView('posts-tab');
        break;
      default:
        await analyticsController?.sendAnalyticsEvent('no-such-tab',{'tabIndex':index});

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

    return Scaffold(
      floatingActionButton: ProfilePageMenu(
        updateMenu: _onItemTapped,
      ),
      key: ObjectKey(chatController),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        // Here we take the value from the LoginPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Logo(),
      ),
      body: ConstrainedBox(
          key: Key(_selectedIndex.toString()),
          constraints: const BoxConstraints(),
          child: _widgetOptions(
              _selectedIndex)), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
