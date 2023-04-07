import 'package:cookout/models/controllers/analytics_controller.dart';
import 'package:cookout/models/post.dart';
import 'package:cookout/shared_components/posts/post_solo.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/clients/api_client.dart';
import '../../models/controllers/auth_controller.dart';
import '../../models/controllers/auth_inherited.dart';
import '../../wrappers/loading_button.dart';

class PostThread extends StatefulWidget {
  const PostThread({super.key});

  @override
  State<PostThread> createState() => _PostThreadState();
}

class _PostThreadState extends State<PostThread> {
  final PagingController<String, Post> _pagingController =
      PagingController(firstPageKey: "");
  AuthController? authController = null;
  late ApiClient client;
  AnalyticsController? analyticsController = null;

  static const _pageSize = 10;

  @override
  void initState() {
    _pagingController.addPageRequestListener((theLastId) async {
      return _fetchPage(theLastId);
    });

    super.initState();
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();

    // var theChatController = AuthInherited.of(context)?.chatController;
    var theAuthController = AuthInherited.of(context)?.authController;
    var theAnalyticsController = AuthInherited.of(context)?.analyticsController;
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
    }

    if(theAnalyticsController != null && analyticsController == null){
      analyticsController = theAnalyticsController;
    }

    // AnalyticsController? theAnalyticsController =
    //     AuthInherited.of(context)?.analyticsController;

    // if(analyticsController == null && theAnalyticsController != null) {
    //   await theAnalyticsController.logScreenView('profiles-page');
    //   analyticsController = theAnalyticsController;
    // }
    if (authController == null && theAuthController != null) {
      authController = authController;
    }
    // myUserId =
    //     AuthInherited.of(context)?.authController?.myAppUser?.userId ?? "";
    // if((widget.profiles?.length??-1) > 0){
    //
    // // profiles = theAuthController;
    //
    // } else {
    //   profiles = await chatController?.updateProfiles();
    // }

    // profiles = await chatController?.updateProfiles();
    setState(() {});
  }

  Future<void> _fetchPage(String pageKey) async {
    print(
        "Retrieving post page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<Post>? newItems;
      newItems = await client.fetchPostsPaginated(pageKey, _pageSize);

      print("Got more items ${newItems.length}");
      final isLastPage = (newItems.length ?? 0) < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems ?? []);
      } else {
        final nextPageKey = newItems.last.id;
        if (nextPageKey != null) {
          _pagingController.appendPage(newItems ?? [], nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PagedListView<String, Post>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Post>(
        noItemsFoundIndicatorBuilder: (build){
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 500, maxWidth: 350),
            child: Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("There are no posts yet."),
                        SizedBox(
                          height: 16,
                        ),
                        LoadingButton(
                          text: "Add a Post",
                          action: () async {
                            await analyticsController?.sendAnalyticsEvent(
                                'add-the-very-first-post',
                                {'frequency_of_event': "once_in_app_history"});
                            Navigator.pushNamed(
                              context,
                              '/createPost',
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        itemBuilder: (context, item, index) => PostSolo(
          post: item,
        ),
      ),
    );
  }
}


