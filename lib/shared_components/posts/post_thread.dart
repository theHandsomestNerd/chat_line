import 'package:cookout/models/clients/api_client.dart';
import 'package:cookout/models/controllers/analytics_controller.dart';
import 'package:cookout/models/controllers/auth_controller.dart';
import 'package:cookout/models/post.dart';
import 'package:cookout/shared_components/posts/post_solo.dart';
import 'package:cookout/wrappers/analytics_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/controllers/auth_inherited.dart';

class PostThread extends StatefulWidget {
  const PostThread({super.key});

  @override
  State<PostThread> createState() => _PostThreadState();
}

class _PostThreadState extends State<PostThread>
    with SingleTickerProviderStateMixin {
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

    if (theAnalyticsController != null && analyticsController == null) {
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

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Container(color: Colors.black87),
      ),
      PagedListView<String, Post>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          noItemsFoundIndicatorBuilder: (build) {
            return Flex(direction: Axis.horizontal, children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 500),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("There are no posts yet."),
                              const SizedBox(
                                height: 16,
                              ),
                              AnalyticsLoadingButton(
                                analyticsEventData: {
                                  'frequency_of_event': "once_in_app_history"
                                },
                                analyticsEventName: 'add-the-very-first-post',
                                text: "Add a Post",
                                action: (context) async {
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
                ),
              ),
            ]);
          },
          itemBuilder: (context, item, index) => Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 1),
            child: PostSolo(
              post: item,
            ),
          ),
        ),
      ),
    ]);
  }
}
