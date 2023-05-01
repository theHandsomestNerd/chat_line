import 'package:cookowt/layout/full_page_layout.dart';
import 'package:cookowt/shared_components/menus/home_page_menu.dart';
import 'package:cookowt/wrappers/app_scaffold_wrapper.dart';
import 'package:cookowt/wrappers/hashtag_collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/clients/api_client.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/post.dart';
import '../shared_components/posts/post_solo.dart';
import '../wrappers/analytics_loading_button.dart';
import 'create_post_page.dart';

class HashtagLibraryPage extends StatefulWidget {
  const HashtagLibraryPage({
    super.key,
  });

  @override
  State<HashtagLibraryPage> createState() => _HashtagLibraryPageState();
}

class _HashtagLibraryPageState extends State<HashtagLibraryPage> {
  @override
  Widget build(BuildContext context) {
    final List<String> hashtagList = [
      "the-lines",
      "numbers",
      "theta-chi",
      "other-bruhs",
      "other-greeks"
    ];
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return AppScaffoldWrapper(
      key: widget.key,
      floatingActionMenu: HomePageMenu(
        updateMenu: () {},
      ),
      child: FullPageLayout(
        child: ListView(
          children: hashtagList.map((element) {
            return Hashtag_Collection_Block(
              collectionSlug: element,
            );
          }).toList(),
        ),
      ),
    );
  }
}
