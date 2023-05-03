import 'package:cookowt/models/clients/api_client.dart';
import 'package:cookowt/models/controllers/auth_controller.dart';
import 'package:cookowt/models/like.dart';
import 'package:cookowt/sanity/sanity_image_builder.dart';
import 'package:cookowt/wrappers/author_and_text.dart';
import 'package:cookowt/wrappers/card_with_actions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/controllers/auth_inherited.dart';
import '../../models/post.dart';

const POST_IMAGE_SQUARE_SIZE = 400;

class PostSolo extends StatefulWidget {
  const PostSolo({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostSolo> createState() => _PostSoloState();
}

class _PostSoloState extends State<PostSolo> {
  AuthController? authController;
  ApiClient? profileClient;
  List<Like> likes = <Like>[];
  Like? isPostLikedByMe;
  bool isLiking = false;

  @override
  didChangeDependencies() async {
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    var theAuthController = AuthInherited.of(context)?.authController;
    // AnalyticsController? theAnalyticsController =
    //     AuthInherited.of(context)?.analyticsController;
    //
    // if(analyticsController == null && theAnalyticsController != null) {
    //   await theAnalyticsController.logScreenView('profiles-page');
    //   analyticsController = theAnalyticsController;
    // }

    if (authController == null && theAuthController != null) {
      authController = theAuthController;
    }
    if (profileClient == null && theClient != null) {
      profileClient = theClient;
    }

    if (widget.post.id != null && theClient != null) {
      await updateLikes();
    }

    // myUserId =
    //     AuthInherited.of(context)?.authController?.myAppUser?.userId ?? "";
    // myBlockedProfiles = await chatController?.updateMyBlocks();
    // setState(() {});
    super.didChangeDependencies();
  }

  updateLikes() async {
    var theLikes = await profileClient?.getProfileLikes(widget.post.id!);
    likes = theLikes?.list ?? [];
    if (theLikes?.list != null) {
      try {
        var myLike = theLikes?.list.firstWhere((element) {
          return element.liker?.userId == authController?.myAppUser?.userId;
        });
        isPostLikedByMe = myLike;
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        isPostLikedByMe = null;
      }
    }
  }

  likeThisPost(String postId) async {
    await profileClient?.like(postId, 'post-like');
  }

  unlikeThisPost(String postId) async {
    if (isPostLikedByMe != null && widget.post.id != null) {
      await profileClient?.unlike(widget.post.id!, isPostLikedByMe!);
    }
  }

  commentOnThisPost(String? postId) {
    GoRouter.of(context).go('/profile/$postId');

    // Navigator.pushNamed(context, '/profile', arguments: {"id": postId});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.post.author != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: AuthorAndText(
              backgroundColor: Colors.white,
              body: widget.post.body,
              when: widget.post.publishedAt,
              author: widget.post.author!,
            ),
          ),
        Flex(
          direction: Axis.horizontal,
          children: [
            if (widget.post.mainImage != null)
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: POST_IMAGE_SQUARE_SIZE as double,
                      minWidth: POST_IMAGE_SQUARE_SIZE as double),
                  child: CardWithActions(
                    isAction1Active: isPostLikedByMe != null,
                    action1Text: "${likes.length} likes",
                    action1Icon: Icons.thumb_up,
                    action2Icon: Icons.comment,
                    action2Text: "comments",
                    isAction1Loading: isLiking,
                    action1OnPressed: () async {
                      setState(() {
                        isLiking = true;
                      });
                      if (widget.post.id != null) {
                        if (isPostLikedByMe == null) {
                          await likeThisPost(widget.post.id!);
                        } else {
                          await unlikeThisPost(widget.post.id!);
                        }
                        var theLikes = await profileClient
                            ?.getProfileLikes(widget.post.id!);
                        likes = theLikes?.list ?? likes;
                        await updateLikes();

                        setState(() {
                          isLiking = false;
                        });
                      }
                    },
                    action2OnPressed: () async {
                      GoRouter.of(context).go('/post/${widget.post.id}');

                      // Navigator.pushNamed(context, '/post',
                      //     arguments: {"id": widget.post.id});
                    },
                    image: SanityImageBuilder.imageProviderFor(
                            sanityImage: widget.post.mainImage,
                            showDefaultImage: true)
                        .image,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
