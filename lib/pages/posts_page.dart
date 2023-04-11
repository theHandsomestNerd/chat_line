import 'package:cookout/layout/full_page_layout.dart';
import 'package:cookout/shared_components/logo.dart';
import 'package:cookout/shared_components/menus/posts_page_menu.dart';
import 'package:cookout/wrappers/app_scaffold_wrapper.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../shared_components/posts/post_thread.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({
    super.key,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return AppScaffoldWrapper(
      floatingActionMenu: PostsPageMenu(
        updateMenu: () {},
      ),
      child: Container(
        margin: EdgeInsets.all(0),
        child: Flex(direction:Axis.horizontal,
            children:[ Expanded(child: PostThread())]),
      ),
    );
  }
}
