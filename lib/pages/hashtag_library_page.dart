import 'package:flutter/material.dart';
import 'package:cookowt/layout/full_page_layout.dart';
import 'package:cookowt/shared_components/menus/home_page_menu.dart';
import 'package:cookowt/wrappers/app_scaffold_wrapper.dart';
import 'package:cookowt/wrappers/hashtag_collection.dart';

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
