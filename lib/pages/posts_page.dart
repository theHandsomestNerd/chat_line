import 'package:cookout/layout/full_page_layout.dart';
import 'package:cookout/models/controllers/auth_inherited.dart';
import 'package:cookout/shared_components/logo.dart';
import 'package:cookout/shared_components/menus/posts_page_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/default_config.dart';
import '../models/app_user.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../models/controllers/post_controller.dart';
import '../models/post.dart';
import '../platform_dependent/image_uploader.dart';
import '../platform_dependent/image_uploader_abstract.dart';
import '../shared_components/posts/post_thread.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({
    super.key,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late AppUser? highlightedProfile = null;

  List<Post> _postsList = [];
  ImageUploader? imageUploader;
  AuthController? authController;
  PostController? postController;
  late AnalyticsController? analyticsController=null;

  @override
  initState() {
    super.initState();
    imageUploader = ImageUploaderImpl();

    _getPosts().then((listOfPosts) {
      _postsList = listOfPosts;
    });
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    AuthController? theAuthController =
        AuthInherited.of(context)?.authController;
    PostController? thePostController =
        AuthInherited.of(context)?.postController;

    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;
    if (analyticsController == null && theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
      theAnalyticsController?.logScreenView('Posts Page');
    }
    if (authController == null && theAuthController != null) {
      authController = theAuthController;
    }
    if (postController == null && thePostController != null) {
      postController = thePostController;
    }
    var thePosts = await _getPosts();
    _postsList = thePosts;
    setState(() {});
    // if (kDebugMode) {
    //   print("dependencies changed profile list");
    // }
  }

  Future<List<Post>> _getPosts() async {
    var thePosts = await postController?.getPosts();
    if (kDebugMode) {
      print("posts $thePosts");
    }
    return thePosts ?? [];
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
      floatingActionButton: PostsPageMenu(
        updateMenu: () {},
      ),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Logo(),
      ),
      body: FullPageLayout(
        child: PostThread(
          analyticsController: analyticsController,
          key: ObjectKey(_postsList),
          posts: _postsList,
        ),
      ),
    );
  }
}
