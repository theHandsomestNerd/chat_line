import 'package:cookout/models/clients/api_client.dart';
import 'package:cookout/models/comment.dart';
import 'package:cookout/models/controllers/analytics_controller.dart';
import 'package:cookout/models/controllers/auth_controller.dart';
import 'package:cookout/models/post.dart';
import 'package:cookout/shared_components/comments/comment_solo.dart';
import 'package:cookout/shared_components/posts/post_solo.dart';
import 'package:cookout/wrappers/analytics_loading_button.dart';
import 'package:cookout/wrappers/author_and_text.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/controllers/auth_inherited.dart';

class PagedCommentThread extends StatefulWidget {
  const PagedCommentThread({super.key, required this.postId, required this.pagingController});

  final PagingController<String, Comment> pagingController;
  final String postId;

  @override
  State<PagedCommentThread> createState() => _PagedCommentThreadState();
}

class _PagedCommentThreadState extends State<PagedCommentThread> {

  AuthController? authController = null;
  late ApiClient client;
  AnalyticsController? analyticsController = null;

  static const _pageSize = 10;

  @override
  void initState() {
    widget.pagingController.addPageRequestListener((theLastId) async {
      return _fetchPage(theLastId);
    });

    //get the comment Thread from the post Id

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
        "Retrieving post comments thread page with pagekey $pageKey and size $_pageSize $client");
    try {
      List<Comment>? newItems;
      newItems = await client.fetchCommentThreadPaginatedForPost(widget.postId, pageKey, _pageSize);

      print("Got more comment items ${newItems.length}");
      final isLastPage = (newItems.length ?? 0) < _pageSize;
      if (isLastPage) {
        widget.pagingController.appendLastPage(newItems ?? []);
      } else {
        final nextPageKey = newItems.last.id;
        if (nextPageKey != null) {
          widget.pagingController.appendPage(newItems ?? [], nextPageKey);
        }
      }
    } catch (error) {
      widget.pagingController.error = error;
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.pagingController.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Container(color: Colors.black87),
      ),
      PagedListView<String, Comment>(
        pagingController: widget.pagingController,
        builderDelegate: PagedChildBuilderDelegate<Comment>(
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
                              const Text("There are no comments yet."),
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
            child: AuthorAndText(
              when: item.publishedAt,
              author: item.author!,
              body: item.commentBody,
            ),
          ),
        ),
      ),
    ]);
  }
}
