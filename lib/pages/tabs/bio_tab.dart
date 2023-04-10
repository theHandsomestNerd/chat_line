import 'package:cookout/models/clients/api_client.dart';
import 'package:cookout/models/controllers/analytics_controller.dart';
import 'package:cookout/models/controllers/chat_controller.dart';
import 'package:cookout/models/extended_profile.dart';
import 'package:cookout/sanity/sanity_image_builder.dart';
import 'package:cookout/shared_components/tool_button.dart';
import 'package:cookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';

import '../../config/default_config.dart';
import '../../models/app_user.dart';
import '../../models/comment.dart';
import '../../models/controllers/auth_inherited.dart';
import '../../models/follow.dart';
import '../../models/like.dart';

const PROFILE_IMAGE_SQUARE_SIZE = 200;

class BioTab extends StatefulWidget {
  const BioTab(
      {super.key,
      required this.id,
      required this.thisProfile,
      required this.profileLikes,
      required this.updateLikes,
      required this.updateBlocks,
      required this.isThisMe,
      required this.profileComments,
      required this.updateComments,
      required this.updateFollows,
      required this.profileLikedByMe,
      required this.profileFollowedByMe,
      required this.profileFollows,
      required this.goToCommentsTab});

  final String id;
  final updateBlocks;
  final goToCommentsTab;
  final updateLikes;
  final updateComments;
  final updateFollows;
  final List<Like>? profileLikes;
  final List<Comment>? profileComments;
  final AppUser? thisProfile;
  final bool? isThisMe;
  final Like? profileLikedByMe;
  final Follow? profileFollowedByMe;
  final List<Follow>? profileFollows;

  @override
  State<BioTab> createState() => _BioTabState();
}

class _BioTabState extends State<BioTab> {
  late ExtendedProfile? extProfile = null;
  late bool _isLiking = false;
  late bool _isFollowing = false;
  late bool _isBlocking = false;

  late ApiClient? profileClient = null;
  late ChatController? chatController = null;
  late AnalyticsController? analyticsController = null;

  @override
  initState() {
    super.initState();
    analyticsController?.logScreenView('profile-bio-tab').then((x) async {
      if (widget.id == "") {
        await analyticsController
            ?.sendAnalyticsEvent('bio-tab-redirect', {"message": "no-id"});

        Navigator.popAndPushNamed(context, '/profilesPage');
      }
    });
    // if (widget.id != null) {
    //   print("NOT NULL !!!!!!!!!!!!!!!!!");
    //   extProfile = widget.chatController.myExtProfile;
    // }
    //
    // _getExtProfile(widget.id!).then((value) {
    //   extProfile = value;
    // });
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theChatController = AuthInherited.of(context)?.chatController;
    var theAnalyticsController = AuthInherited.of(context)?.analyticsController;
    extProfile =
        await theChatController?.profileClient.getExtendedProfile(widget.id);
    profileClient = theChatController?.profileClient;
    chatController = theChatController;
    if (theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
    }
    setState(() {});
  }

  _likeThisProfile(context) async {
    await analyticsController
        ?.sendAnalyticsEvent('profile-like-press', {"liked": widget.id});

    setState(() {
      _isLiking = true;
    });
    String? likeResponse = null;
    bool isUnlike = false;

    if (widget.profileLikedByMe == null) {
      likeResponse = await profileClient?.like(widget.id, 'profile-like');
    } else {
      if (widget.profileLikedByMe != null) {
        isUnlike = true;
        likeResponse = await profileClient?.unlike(
            widget.id, widget.profileLikedByMe!);
      }
    }

    await widget.updateLikes(context, likeResponse, isUnlike);
    setState(() {
      _isLiking = false;
    });
  }

  _followThisProfile(context) async {
    await analyticsController
        ?.sendAnalyticsEvent('profile-follow-press', {"followed": widget.id});

    setState(() {
      _isFollowing = true;
    });
    String? followResponse;
    bool isUnfollow = false;

    if (widget.profileFollowedByMe == null) {
      followResponse = await profileClient?.followProfile(widget.id);
    } else {
      if (widget.profileFollowedByMe != null) {
        isUnfollow = true;
        followResponse = await profileClient?.unfollowProfile(
            widget.id, widget.profileFollowedByMe!);
      }
    }

    await widget.updateFollows(context, followResponse, isUnfollow);

    setState(() {
      _isFollowing = false;
    });
  }

  _blockThisProfile(context) async {
    await analyticsController?.sendAnalyticsEvent('profile-block-press', {
      "blocked": widget.id,
    });

    setState(() {
      _isBlocking = true;
    });
    String? blockResponse;

    blockResponse = await profileClient?.blockProfile(widget.id);
    setState(() {
      _isBlocking = false;
    });

    await widget.updateBlocks(context, blockResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Flex(direction: Axis.vertical, children: [
        Expanded(
          flex: 1,
          child: ListView(
            children: [
              ListTile(
                title: ConstrainedBox(
                  constraints: const BoxConstraints(),
                  child: Row(
                    key: ObjectKey(widget.thisProfile?.profileImage),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.thisProfile?.profileImage != null
                          ? Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Hero(
                                    tag: widget.thisProfile?.userId ??
                                        "default-image",
                                    child: SizedBox(
                                      height: 350.0,
                                      width: 350.0,
                                      child: CardWithBackground(
                                        width: 350,
                                        height: 350,
                                        image: SanityImageBuilder.imageProviderFor(sanityImage: widget.thisProfile?.profileImage,showDefaultImage: true).image,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ConstrainedBox(
                                              constraints:
                                                  BoxConstraints(maxWidth: 320),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Flex(
                                                      direction:
                                                          Axis.horizontal,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    8,
                                                                    24,
                                                                    0,
                                                                    8),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                ToolButton(
                                                                  isDisabled:
                                                                      (widget.isThisMe ==
                                                                          true),
                                                                  // key: ObjectKey(
                                                                  //     chatController?.myBlockedProfiles),
                                                                  action:
                                                                      _blockThisProfile,
                                                                  iconData: Icons
                                                                      .block,
                                                                  color: Colors
                                                                      .red,
                                                                  isLoading:
                                                                      _isBlocking,
                                                                  // text: "Block",
                                                                  isHideLabel:
                                                                      true,
                                                                  label:
                                                                      'Block',
                                                                  isActive: chatController
                                                                      ?.isProfileBlockedByMe(
                                                                          widget
                                                                              .id),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(.5),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                child: Flex(
                                                  key: ObjectKey((widget
                                                          .profileLikes
                                                          .toString()) +
                                                      (widget.profileFollows
                                                          .toString()) +
                                                      (widget.profileComments
                                                          .toString())),
                                                  direction: Axis.horizontal,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Flexible(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ToolButton(
                                                            defaultColor:
                                                                Colors.white,
                                                            isDisabled: (widget
                                                                    .isThisMe ==
                                                                true),
                                                            action:
                                                                _likeThisProfile,
                                                            iconData:
                                                                Icons.thumb_up,
                                                            color: Colors.green,
                                                            isLoading:
                                                                _isLiking,
                                                            text: widget
                                                                .profileLikes
                                                                ?.length
                                                                .toString(),
                                                            label: 'Like',
                                                            isActive: widget
                                                                    .profileLikedByMe !=
                                                                null,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ToolButton(
                                                              defaultColor:
                                                                  Colors.white,
                                                              isDisabled: (widget
                                                                      .isThisMe ==
                                                                  true),
                                                              action:
                                                                  _followThisProfile,
                                                              text: widget
                                                                  .profileFollows
                                                                  ?.length
                                                                  .toString(),
                                                              isActive: widget
                                                                      .profileFollowedByMe !=
                                                                  null,
                                                              iconData: Icons
                                                                  .favorite,
                                                              isLoading:
                                                                  _isFollowing,
                                                              color:
                                                                  Colors.blue,
                                                              label: 'Follow'),
                                                        ],
                                                      ),
                                                    ),
                                                    // const Divider(
                                                    //   color: Colors.black12,
                                                    //   thickness: 2,
                                                    // ),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ToolButton(
                                                              defaultColor:
                                                                  Colors.white,
                                                              isDisabled: (widget
                                                                      .isThisMe ==
                                                                  true),
                                                              // key: ObjectKey(
                                                              //     "${widget.profileComments?.length}-comments"),
                                                              text: widget
                                                                  .profileComments
                                                                  ?.length
                                                                  .toString(),
                                                              action:
                                                                  (context) {
                                                                widget
                                                                    .goToCommentsTab();
                                                              },
                                                              iconData:
                                                                  Icons.comment,
                                                              color:
                                                                  Colors.yellow,
                                                              label: 'Comment'),
                                                        ],
                                                      ),
                                                    ),
                                                    // const Divider(
                                                    //   color: Colors.black12,
                                                    //   thickness: 2,
                                                    // ),

                                                    // const Divider(
                                                    //   color: Colors.black12,
                                                    //   thickness: 2,
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: PROFILE_IMAGE_SQUARE_SIZE as double,
                              width: PROFILE_IMAGE_SQUARE_SIZE as double,
                              child: Text(
                                  widget.thisProfile?.profileImage.toString() ??
                                      ""),
                            ),
                      // SizedBox(
                      //   width: 150,
                      //   key: ObjectKey((widget.profileLikes.toString()) +
                      //       (widget.profileFollows.toString()) +
                      //       (widget.profileComments.toString())),
                      //   child: Column(
                      //     children: [
                      //       const Divider(
                      //         color: Colors.black12,
                      //         thickness: 2,
                      //       ),
                      //       ListTile(
                      //         title: ToolButton(
                      //           isDisabled: (widget.isThisMe == true),
                      //           action: _likeThisProfile,
                      //           iconData: Icons.thumb_up,
                      //           color: Colors.green,
                      //           isLoading: _isLiking,
                      //           text: widget.profileLikes?.length.toString(),
                      //           label: 'Like',
                      //           isActive: widget.profileLikedByMe != null,
                      //         ),
                      //       ),
                      //       const Divider(
                      //         color: Colors.black12,
                      //         thickness: 2,
                      //       ),
                      //       ListTile(
                      //         // key:
                      //         // ObjectKey("${widget.profileFollows}-follows"),
                      //         title: ToolButton(
                      //             isDisabled: (widget.isThisMe == true),
                      //             action: _followThisProfile,
                      //             text:
                      //                 widget.profileFollows?.length.toString(),
                      //             isActive: widget.profileFollowedByMe != null,
                      //             iconData: Icons.favorite,
                      //             isLoading: _isFollowing,
                      //             color: Colors.blue,
                      //             label: 'Follow'),
                      //       ),
                      //       const Divider(
                      //         color: Colors.black12,
                      //         thickness: 2,
                      //       ),
                      //       ListTile(
                      //         title: ToolButton(
                      //             isDisabled: (widget.isThisMe == true),
                      //             // key: ObjectKey(
                      //             //     "${widget.profileComments?.length}-comments"),
                      //             text:
                      //                 widget.profileComments?.length.toString(),
                      //             action: (context) {
                      //               widget.goToCommentsTab();
                      //             },
                      //             iconData: Icons.comment,
                      //             color: Colors.yellow,
                      //             label: 'Comment'),
                      //       ),
                      //       const Divider(
                      //         color: Colors.black12,
                      //         thickness: 2,
                      //       ),
                      //       ListTile(
                      //         title: ToolButton(
                      //           isDisabled: (widget.isThisMe == true),
                      //           // key: ObjectKey(
                      //           //     chatController?.myBlockedProfiles),
                      //           action: _blockThisProfile,
                      //           iconData: Icons.block,
                      //           color: Colors.red,
                      //           isLoading: _isBlocking,
                      //           text: "Block",
                      //           label: 'Block',
                      //           isActive: chatController
                      //               ?.isProfileBlockedByMe(widget.id),
                      //         ),
                      //       ),
                      //       const Divider(
                      //         color: Colors.black12,
                      //         thickness: 2,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: ConstrainedBox(
                  constraints: const BoxConstraints(),
                  child: Row(
                    children: [
                      Text(
                        widget.thisProfile?.displayName ?? "",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: ConstrainedBox(
                  constraints: const BoxConstraints(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.pin_drop,
                            size: 32.0,
                            semanticLabel: "Location",
                          ),
                          Text('mi. away'),
                        ],
                      ),
                      if (extProfile?.whereILive?.isNotEmpty == true)
                        Column(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    children: const [
                                      Text("Where I Live?"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(extProfile?.whereILive ?? ""),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(
                color: Colors.black12,
                thickness: 2,
              ),
              ListTile(
                title: ConstrainedBox(
                  constraints: const BoxConstraints(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (extProfile?.age != null &&
                          ((extProfile?.age ?? 0) > 0) == true)
                        Flexible(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${extProfile?.age.toString()}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  Text(
                                    "years",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (extProfile?.height != null &&
                              ((extProfile?.height?.feet ?? 0) > 0) == true ||
                          (extProfile?.height?.inches ?? 0) > 0 == true)
                        Flexible(
                          child: Row(
                            children: [
                              Text(
                                ("${extProfile?.height?.feet}'"),
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const Text(""),
                              Text(
                                "${extProfile?.height?.inches}\"",
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                      if (extProfile?.weight != null &&
                          ((extProfile?.weight ?? 0) > 0) == true)
                        Flexible(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${extProfile?.weight.toString()}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  Text(
                                    " lbs",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(
                color: Colors.black12,
                thickness: 2,
              ),
              if (extProfile?.shortBio?.isNotEmpty == true)
                ListTile(
                  title: ConstrainedBox(
                    constraints: const BoxConstraints(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: const [
                            Text("Short Bio"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(extProfile?.shortBio ?? ""),
                ),
              if (extProfile?.longBio?.isNotEmpty == true)
                ListTile(
                  title: Column(
                    children: const [Text("Long Bio")],
                  ),
                  subtitle: Text(extProfile?.longBio ?? ""),
                ),
              if (extProfile?.iAm?.isNotEmpty == true)
                ExpansionTile(
                  subtitle: Text(extProfile?.iAm ?? ""),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: const [Text("I am")],
                      ),
                    ],
                  ),
                ),
              if (extProfile?.imInto?.isNotEmpty == true)
                ExpansionTile(
                  subtitle: Text(extProfile?.imInto ?? ""),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: const [Text("I'm Into")],
                      ),
                    ],
                  ),
                ),
              if (extProfile?.imOpenTo?.isNotEmpty == true)
                ExpansionTile(
                  subtitle: Text(extProfile?.imOpenTo ?? ""),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: const [Text("I'm Open to")],
                      ),
                    ],
                  ),
                ),
              if (extProfile?.whatIDo?.isNotEmpty == true)
                ExpansionTile(
                  subtitle: Text(extProfile?.whatIDo ?? ""),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: const [Text("What I do")],
                      ),
                    ],
                  ),
                ),
              if (extProfile?.whatImLookingFor?.isNotEmpty == true)
                ExpansionTile(
                  subtitle: Text(extProfile?.whatImLookingFor ?? ""),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: const [Text("What I'm looking for")],
                      ),
                    ],
                  ),
                ),
              if (extProfile?.whatInterestsMe?.isNotEmpty == true)
                ExpansionTile(
                  subtitle: Text(extProfile?.whatInterestsMe ?? ""),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: const [Text("What Interests me")],
                      ),
                    ],
                  ),
                ),
              if (extProfile?.sexPreferences?.isNotEmpty == true)
                ListTile(
                  title: ConstrainedBox(
                    constraints: const BoxConstraints(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: const [
                            Text("Sex Preferences?"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(extProfile?.sexPreferences ?? ""),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}
