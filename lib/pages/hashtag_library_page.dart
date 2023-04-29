import 'package:cookowt/shared_components/menus/home_page_menu.dart';
import 'package:cookowt/wrappers/app_scaffold_wrapper.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lines", style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/FA76");
                },
                child: Text(
                  "#FA76",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/FA99");
                },
                child: Text(
                  "#FA99",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/FA00");
                },
                child: Text(
                  "#FA00",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/SP02");
                },
                child: Text(
                  "#SP02",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/SP06");
                },
                child: Text(
                  "#SP06",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/SP08");
                },
                child: Text(
                  "#SP08",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/FA08");
                },
                child: Text(
                  "#FA08",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          Text("Numbers", style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/1s");
                },
                child: Text(
                  "#1s",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/2s");
                },
                child: Text(
                  "#2s",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/3s");
                },
                child: Text(
                  "#3s",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/4s");
                },
                child: Text(
                  "#4s",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/5s");
                },
                child: Text(
                  "#5s",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/6s");
                },
                child: Text(
                  "#6s",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/7s");
                },
                child: Text(
                  "#7s",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          Text("Theta Chi", style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/ThetaChiBruhs");
                },
                child: Text(
                  "#ThetaChiBruhs",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8,),
              MaterialButton(
                color: Colors.black87,
                onPressed: () {
                  GoRouter.of(context).go("/hashtag/ThetaChiHearts");
                },
                child: Text(
                  "#ThetaChiHearts",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 32,),
          MaterialButton(
            color: Colors.black87,
            onPressed: () {
              GoRouter.of(context).go("/hashtag/OtherGreeks");
            },
            child: Text(
              "#OtherGreeks",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
