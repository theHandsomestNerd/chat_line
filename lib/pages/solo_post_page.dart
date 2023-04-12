import 'package:cookout/layout/full_page_layout.dart';
import 'package:cookout/layout/list_and_small_form.dart';
import 'package:cookout/models/clients/api_client.dart';
import 'package:cookout/models/controllers/auth_controller.dart';
import 'package:cookout/models/controllers/auth_inherited.dart';
import 'package:cookout/models/like.dart';
import 'package:cookout/models/responses/chat_api_get_profile_likes_response.dart';
import 'package:cookout/sanity/sanity_image_builder.dart';
import 'package:cookout/shared_components/comments/paged_comment_thread.dart';
import 'package:cookout/shared_components/tool_button.dart';
import 'package:cookout/wrappers/analytics_loading_button.dart';
import 'package:cookout/wrappers/app_scaffold_wrapper.dart';
import 'package:cookout/wrappers/author_and_text.dart';
import 'package:cookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/comment.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/post_controller.dart';
import '../models/post.dart';
import '../wrappers/alerts_snackbar.dart';

class SoloPostPage extends StatefulWidget {
  const SoloPostPage({Key? key, this.thisPostId}) : super(key: key);

  final String? thisPostId;

  @override
  State<SoloPostPage> createState() => _SoloPostPageState();
}

class _SoloPostPageState extends State<SoloPostPage> {
  bool _isCommenting = false;
  String? commentBody = "";
  ApiClient? profileClient;
  String? thisPostId;
  final PagingController<String, Comment> _pagingController =
      PagingController(firstPageKey: "");

  AnalyticsController? analyticsController;
  late Post? thePost = null;
  late PostController? postController = null;
  String status = "";

  _commentThisProfile() async {
    _isCommenting = true;
    if (profileClient != null && thisPostId != null && commentBody != null) {
      var thestatus = await profileClient!
          .commentProfile(thisPostId!, commentBody!, 'post-comment');
      status = thestatus;
    }

    commentBody = "";
    _isCommenting = false;
    setState(() {});
  }

  _setCommentBody(e) {
    commentBody = e;
    setState(() {});
  }

  @override
  initState() {
    // thePost= postController?.getPost(thisPostId);
    thisPostId = widget.thisPostId;
  }
  late Like? _profileLikedByMe = null;
  late List<Like>? _profileLikes = [];
  final AlertSnackbar _alertSnackbar = AlertSnackbar();


  AuthController? authController = null;

  Future<ChatApiGetProfileLikesResponse?> _getProfileLikes() async {
    return await profileClient?.getProfileLikes(widget.thisPostId??"");
  }
  updateLikes(innerContext, String likeResponse, bool isUnlike) async {
  ChatApiGetProfileLikesResponse? theLikes = await _getProfileLikes();

  await analyticsController?.sendAnalyticsEvent('profile-liked', {
  "likee": widget.thisPostId ?? "",
  "liker": authController?.myAppUser?.userId ?? "",
  "isUnlike": isUnlike.toString()
  });

  setState(() {
  _profileLikes = theLikes?.list;
  _profileLikedByMe = theLikes?.amIInThisList;
  });

  if (!isUnlike && likeResponse != "SUCCESS") {
  _alertSnackbar.showErrorAlert(
  "That ${isUnlike ? "unlike" : "like"} didnt register. Try Again.",
  innerContext);
  } else {
  _alertSnackbar.showSuccessAlert(
  "You ${isUnlike ? "unlike" : "like"} this profile.",
  innerContext);
  }
}

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theAuthController = AuthInherited.of(context)?.authController;
    authController = theAuthController;
    var theChatController = AuthInherited.of(context)?.chatController;

    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;
    PostController? thePostController =
        AuthInherited.of(context)?.postController;
    if (thePostController != null && thePost == null) {
      postController = thePostController;
      var aPost = await thePostController.getPost(thisPostId ?? "");
      if (aPost != null) {
        thePost = aPost;
        // print("A post retrieved $aPost");
      }
    }
    var theLikes = await theChatController?.profileClient
        .getProfileLikes(widget.thisPostId??"") as ChatApiGetProfileLikesResponse;

    _profileLikedByMe = theLikes.amIInThisList;
    _profileLikes = theLikes.list;


    theAnalyticsController?.logScreenView('Post');
    if (theAnalyticsController != null && analyticsController == null) {
      analyticsController = theAnalyticsController;
    }

    ApiClient? theClient =
        AuthInherited.of(context)?.chatController?.profileClient;

    if (theClient != null && profileClient == null) {
      profileClient = theClient;
    }

    setState(() {});
  }
  late bool _isLiking = false;
late Like? profileLikedByMe = null;

  _likeThisProfile(context) async {
    await analyticsController
        ?.sendAnalyticsEvent('profile-like-press', {"liked": widget.thisPostId});

    setState(() {
      _isLiking = true;
    });
    String? likeResponse = null;
    bool isUnlike = false;

    if (profileLikedByMe == null) {
      likeResponse = await profileClient?.like(widget.thisPostId??"", 'profile-like');
    } else {
      if (profileLikedByMe != null) {
        isUnlike = true;
        likeResponse = await profileClient?.unlike(
            widget.thisPostId??"", profileLikedByMe!);
      }
    }

    await updateLikes(context, likeResponse ?? "", isUnlike);
    setState(() {
      _isLiking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldWrapper(
      child: FullPageLayout(
        child: SlidingUpPanel(
          // header: Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SizedBox(
          //     height: 2,
          //     width: 50,
          //     child: Container(color: Colors.red),
          //   ),
          // ),
          backdropEnabled: true,
          isDraggable: true,
          parallaxEnabled: true,
          maxHeight: 600,
          color: Colors.transparent,
          minHeight: 100,
          body: Stack(children: [
            Flex(
              direction: Axis.vertical,
              children: [
                Flexible(
                  flex: 4,
                  child: CardWithBackground(
                    image: SanityImageBuilder.imageProviderFor(
                            sanityImage: thePost?.mainImage)
                        .image,
                    child: Container(),
                  ),
                ),
              ],
            ),
            if (thePost?.author != null)
              Column(
                children: [
                  AuthorAndText(
                    author: thePost!.author!,
                    when: thePost!.publishedAt!,
                    body: thePost!.body!,
                  ),
                ],
              )
          ]),
          panelBuilder: (scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 2,
                        width: 50,
                        child: Container(color: Colors.red),
                      ),
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 48),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ToolButton(
                                    action:
                                    _likeThisProfile,
                                    iconData:
                                    Icons.thumb_up,
                                    color: Colors.green,
                                    isLoading:
                                    _isLiking,
                                    text: _profileLikes
                                        ?.length
                                        .toString(),
                                    label: 'Like',
                                    isActive: profileLikedByMe !=
                                        null,
                                   ),
                                ToolButton(
                                    action: () {},
                                    iconData: Icons.comment,
                                    color: Colors.blue,
                                    label: "0"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (thePost?.author != null)
                      Column(
                        children: [
                          AuthorAndText(
                            author: thePost!.author!,
                            when: thePost!.publishedAt!,
                            body: thePost!.body!,
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 3,
                      child: Container(color: Colors.red),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: thePost?.id != null
                          ? PagedCommentThread(
                              key: Key(thisPostId ?? ""),
                              pagingController: _pagingController,
                              postId: thePost!.id!,
                            )
                          : Container(),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 180),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                autofocus: true,
                                onChanged: (e) {
                                  _setCommentBody(e);
                                },
                                initialValue: commentBody,
                                minLines: 2,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Comment:',
                                ),
                              ),
                              SizedBox(height: 8),
                              AnalyticsLoadingButton(
                                isDisabled: _isCommenting,
                                analyticsEventName: 'solo-post-create-comment',
                                analyticsEventData: {
                                  'author': thePost?.author?.userId,
                                  "body": commentBody ?? "",
                                },
                                action: (x) async {
                                  await _commentThisProfile();
                                  commentBody = "";
                                  setState(() {});
                                  _pagingController.refresh();
                                },
                                text: "Comment",
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),]
            ),
          ),
        ),
      ),
    );
  }
}
