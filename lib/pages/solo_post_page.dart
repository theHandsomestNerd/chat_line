import 'package:kookout/layout/full_page_layout.dart';
import 'package:kookout/models/clients/api_client.dart';
import 'package:kookout/models/controllers/auth_controller.dart';
import 'package:kookout/models/controllers/auth_inherited.dart';
import 'package:kookout/models/like.dart';
import 'package:kookout/models/responses/chat_api_get_profile_likes_response.dart';
import 'package:kookout/sanity/sanity_image_builder.dart';
import 'package:kookout/shared_components/comments/paged_comment_thread.dart';
import 'package:kookout/shared_components/tool_button.dart';
import 'package:kookout/wrappers/analytics_loading_button.dart';
import 'package:kookout/wrappers/app_scaffold_wrapper.dart';
import 'package:kookout/wrappers/author_and_text.dart';
import 'package:kookout/wrappers/card_with_background.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hashtagable/hashtagable.dart';
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
  Post? thePost;
  PostController? postController;
  String status = "";
  List<Comment>? _profileComments = [];

  _getProfileComments() async {
    if (profileClient != null && widget.thisPostId != null) {
      var comments = await profileClient?.getProfileComments(
          widget.thisPostId!, 'post-comment');
      if (kDebugMode) {
        print(
        "The COmments retreived profClient:$profileClient ${widget.thisPostId} $comments",
      );
      }
      return comments;
    }
  }

  updateComments(innerContext, String commentResponse, bool isUncomment) async {
    if (commentResponse == "SUCCESS") {
      await analyticsController?.sendAnalyticsEvent('comment-made', {
        "commentee": widget.thisPostId.toString(),
        "commented": authController?.myAppUser?.userId
      });
      List<Comment> theComments = await _getProfileComments() ?? [];

      setState(() {
        // _isCommenting = false;
        _profileComments = theComments;
      });
    }
  }

  _commentThisProfile() async {
    _isCommenting = true;
    setState(() {});
    if (profileClient != null && thisPostId != null && commentBody != null) {
      var thestatus = await profileClient!
          .commentDocument(thisPostId!, commentBody!, 'post-comment');
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
    super.initState();
    // thePost= postController?.getPost(thisPostId);
    thisPostId = widget.thisPostId;
  }

  Like? _profileLikedByMe;
  late List<Like>? _profileLikes = [];
  final AlertSnackbar _alertSnackbar = AlertSnackbar();

  AuthController? authController;

  Future<ChatApiGetProfileLikesResponse?> _getProfileLikes() async {
    return await profileClient?.getProfileLikes(widget.thisPostId ?? "");
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
          "You ${isUnlike ? "unlike" : "like"} this profile.", innerContext);
    }
  }

  @override
  didChangeDependencies() async {
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
            .getProfileLikes(widget.thisPostId ?? "")
        as ChatApiGetProfileLikesResponse;

    _profileLikedByMe = theLikes.amIInThisList;
    _profileLikes = theLikes.list;

    // var isUncomment = false;
    // var commentResponse = await updateComments(context, "SUCCESS", false);
    // _alertSnackbar.showSuccessAlert(
    //     "That ${isUncomment == true ? "Uncomment" : "Comment"} ", context);

    // if (commentResponse != "SUCCESS") {
    //   _alertSnackbar.showErrorAlert(
    //       "That ${isUncomment == true ? "Uncomment" : "Comment"} didnt register. Try Again.",
    //       context);
    // } else {
    //   _alertSnackbar.showSuccessAlert(
    //       "That ${isUncomment == true ? "Uncomment" : "Comment"} ",
    //       context);
    // }
    theAnalyticsController?.logScreenView('Post');
    if (theAnalyticsController != null && analyticsController == null) {
      analyticsController = theAnalyticsController;
    }

    ApiClient? theClient = theChatController?.profileClient;

    if (theClient != null && profileClient == null) {
      profileClient = theClient;
    }

    if (theClient != null) {
      var theComments = await _getProfileComments();
      if (theComments != null) {
        _profileComments = theComments;
      }
    }
    setState(() {});
    super.didChangeDependencies();
  }

  late bool _isLiking = false;

  _likeThisProfile(context) async {
    await analyticsController?.sendAnalyticsEvent(
        'profile-like-press', {"liked": widget.thisPostId});

    setState(() {
      _isLiking = true;
    });
    String? likeResponse;
    bool isUnlike = false;

    if (_profileLikedByMe == null) {
      likeResponse =
          await profileClient?.like(widget.thisPostId ?? "", 'profile-like');
    } else {
      if (_profileLikedByMe != null) {
        isUnlike = true;
        likeResponse = await profileClient?.unlike(
            widget.thisPostId ?? "", _profileLikedByMe!);
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
            child: Column(children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
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
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ToolButton(
                                  action: _likeThisProfile,
                                  iconData: Icons.thumb_up,
                                  color: Colors.green,
                                  isLoading: _isLiking,
                                  text: _profileLikes?.length.toString(),
                                  label: 'Like',
                                  isActive: _profileLikedByMe != null,
                                ),
                                ToolButton(
                                    action: () {},
                                    iconData: Icons.comment,
                                    color: Colors.blue,
                                    text:
                                        "${_profileComments?.length} comments",
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
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: thePost?.id != null
                          ? PagedCommentThread(
                              key: Key(thisPostId ?? ""),
                              pagingController: _pagingController,
                              postId: thePost!.id!,
                            )
                          : Container(),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 180),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              HashTagTextField(
                                onChanged: (e) {
                                  _setCommentBody(e);
                                },
                                // value: commentBody,
                                minLines: 2,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Comment:',
                                ),
                              ),
                              const SizedBox(height: 8),
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
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
