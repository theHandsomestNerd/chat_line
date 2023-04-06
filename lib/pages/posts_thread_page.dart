import 'package:cookout/pages/tabs/profile_list_tab.dart';
import 'package:flutter/material.dart';

import '../config/default_config.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../shared_components/logo.dart';

class PostsThreadPage extends StatefulWidget {
  const PostsThreadPage({
    super.key,
  });

  @override
  State<PostsThreadPage> createState() => _PostsThreadPageState();
}

class _PostsThreadPageState extends State<PostsThreadPage> {
  int _selectedIndex = 0;
  late AnalyticsController analyticsController;

  @override
  void initState() {
    super.initState();
    // widget.chatController.updateProfiles();
  }

  didChangeDependencies() async {
    super.didChangeDependencies();
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    theAnalyticsController?.logScreenView('posts-thread');
    if (analyticsController == null && theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
    }
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  Widget _widgetOptions(selectedIndex) {
    var theOptions = <Widget>[
      ProfileListTab(),
      const Text(
        'Index 2: Timeline',
        style: optionStyle,
      ),
      const Text(
        'Index 3: Likes and Follows',
        style: optionStyle,
      ),
      const Text(
        'Index 4: Albums',
        style: optionStyle,
      ),
      const Text(
        'Index 4: Posts',
        style: optionStyle,
      ),
    ];

    return theOptions.elementAt(selectedIndex);
  }

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        await analyticsController
            .logScreenView('posts-thread-page-profile-list-tab');
        break;
      default:
        await analyticsController
            .logScreenView('posts-thread-page-${index}-tab-press');
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
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.5),
          // Here we take the value from the LoginPage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Logo(),
        ),
        body: ConstrainedBox(
            key: Key(_selectedIndex.toString()),
            constraints: const BoxConstraints(),
            child: _widgetOptions(_selectedIndex)),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Profiles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_emotions),
              label: 'Relationships',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_album),
              label: 'Albums',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add),
              label: 'Posts',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.red[800],
          unselectedItemColor: Colors.black,
          onTap:
              _onItemTapped, // This trailing comma makes auto-formatting nicer for build methods.
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
