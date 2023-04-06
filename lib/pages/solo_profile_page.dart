import 'package:cookout/models/clients/api_client.dart';
import 'package:cookout/models/controllers/auth_controller.dart';
import 'package:cookout/models/controllers/chat_controller.dart';
import 'package:cookout/models/responses/chat_api_get_profile_follows_response.dart';
import 'package:cookout/models/responses/chat_api_get_profile_likes_response.dart';
import 'package:cookout/pages/tabs/bio_tab.dart';
import 'package:cookout/pages/tabs/comments_tab.dart';
import 'package:cookout/pages/tabs/follows_tab.dart';
import 'package:cookout/pages/tabs/likes_tab.dart';
import 'package:cookout/wrappers/alerts_snackbar.dart';
import 'package:flutter/material.dart';

import '../config/default_config.dart';
import '../models/comment.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/follow.dart';
import '../models/like.dart';
import '../shared_components/logo.dart';
import '../shared_components/menus/app_menu.dart';

class SoloProfilePage extends StatefulWidget {
  const SoloProfilePage({
    super.key,
    required this.id,
    required this.thisProfile,
  });

  final String id;
  final thisProfile;

  @override
  State<SoloProfilePage> createState() => _SoloProfilePageState();
}

class _SoloProfilePageState extends State<SoloProfilePage> {
  late bool _isThisMe = false;

  late List<Comment>? _profileComments = [];

  late Like? _profileLikedByMe = null;
  late List<Like>? _profileLikes = [];

  late Follow? _profileFollowedByMe = null;
  late List<Follow>? _profileFollows = [];

  final AlertSnackbar _alertSnackbar = AlertSnackbar();
  AnalyticsController? analyticsController=null;
  ApiClient? profileClient = null;
  AuthController? authController = null;
  ChatController? chatController = null;

  SoloProfilePage() {
    if (widget.id == "") {
      Navigator.popAndPushNamed(context, '/profilesPage');
    }
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theChatController = AuthInherited.of(context)?.chatController;
    var theAuthController = AuthInherited.of(context)?.authController;
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    theAnalyticsController
        ?.logScreenView(_isThisMe ? 'My Profile Page' : 'Profile Page');

    if (analyticsController==null && theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
    }
    var theFollows = await theChatController?.profileClient
        .getProfileFollows(widget.id) as ChatApiGetProfileFollowsResponse;
    var theLikes = await theChatController?.profileClient
        .getProfileLikes(widget.id) as ChatApiGetProfileLikesResponse;
    var theComments =
        await theChatController?.profileClient.getProfileComments(widget.id) ??
            [];

    _profileComments = theComments;
    _profileLikes = theLikes.list;
    _profileFollows = theFollows.list;
    _profileFollowedByMe = theFollows.amIInThisList;

    _profileLikedByMe = theLikes.amIInThisList;
    // var theProfile = await theAuthController?.getAppUser(widget.id);

    // if (kDebugMode) {
    //   print("the profile retrieved in this page $theProfile ");
    // }

    profileClient = theChatController?.profileClient;
    authController = theAuthController;

    _isThisMe = widget.id == theAuthController?.myAppUser?.userId;

    setState(() {});
    // if (kDebugMode) {
    //   print("profile  dependencies changed is this me $_isThisMe");
    // }
  }

  _getTagLine() {
    if (_isThisMe == true) {
      return "This is you ${authController?.myAppUser?.displayName ?? ""}";
    }
    return widget.thisProfile?.displayName;
  }

  Future<ChatApiGetProfileLikesResponse?> _getProfileLikes() async {
    return await profileClient?.getProfileLikes(widget.id);
  }

  _getProfileFollows() async {
    return profileClient?.getProfileFollows(widget.id);
  }

  _getProfileComments() async {
    return profileClient?.getProfileComments(widget.id);
  }

  // isThisProfileLikedByMe(List<Like> theLikes) {
  //   Like? profileLikedByMe;
  //   for (var like in theLikes) {
  //     if (like.liker?.userId ==
  //         authController?.loggedInUser?.uid) {
  //       if (kDebugMode) {
  //         print(
  //             "I'm ${authController?.loggedInUser?.uid} in the likes?");
  //       }
  //       profileLikedByMe = like;
  //     }
  //   }
  //
  //   return profileLikedByMe;
  // }

  isThisProfileFollowedByMe(List<Follow> theFollows) {
    Follow? profileFollowedByMe;
    for (var follow in theFollows) {
      if (follow.follower?.userId == authController?.loggedInUser?.uid) {
        profileFollowedByMe = follow;
      }
    }

    return profileFollowedByMe;
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  Widget _widgetOptions(selectedIndex) {
    var theOptions = <Widget>[
      BioTab(
        goToCommentsTab: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        thisProfile: widget.thisProfile,
        profileLikes: _profileLikes,
        id: widget.id,
        updateBlocks: (innercontext, String blockResponse) async {
          // List<Block> theBlocks = await _getProfileBlocks();

          if (blockResponse != "SUCCESS") {
            _alertSnackbar.showErrorAlert(
                "That block didnt register. Try Again.", innercontext);
          } else {
            await analyticsController?.sendAnalyticsEvent('profile-blocked', {
              "blocked": widget.id,
              "blocker": authController?.myAppUser?.userId,
            });
            await chatController?.updateMyBlocks();
            _alertSnackbar.showSuccessAlert(
                "You blocked this user. Ew!", innercontext);

            Navigator.popAndPushNamed(innercontext, '/profilesPage');
          }
        },
        profileFollows: _profileFollows,
        updateLikes: (innerContext, String likeResponse, bool isUnlike) async {
          ChatApiGetProfileLikesResponse? theLikes = await _getProfileLikes();

          await analyticsController?.sendAnalyticsEvent('profile-liked', {
            "likee": widget.id ??"",
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
        },
        updateFollows:
            (innerContext, String followResponse, bool isUnfollow) async {
          if (followResponse != "SUCCESS") {
            _alertSnackbar.showErrorAlert(
                "That ${isUnfollow == true ? "Unfollow" : "Follow"} didnt register. Try Again.",
                innerContext);
          } else {
            await analyticsController?.sendAnalyticsEvent('profile-follow', {
              "followed": widget.id ??"",
              "follower": authController?.myAppUser?.userId??"",
              "isUnfollow": isUnfollow.toString()
            });
            ChatApiGetProfileFollowsResponse theFollows =
                await _getProfileFollows();
            Follow? isFollowdResponse = theFollows.amIInThisList;
            setState(() {
              _profileFollows = theFollows.list;
              _profileFollowedByMe = isFollowdResponse;
            });
            _alertSnackbar.showSuccessAlert(
                "You ${isUnfollow == true ? "Unfollowed" : "Followed"} the user.",
                innerContext);
          }
        },
        isThisMe: _isThisMe,
        profileComments: _profileComments,
        updateComments:
            (innerContext, String commentResponse, bool isUncomment) async {
          if (commentResponse != "SUCCESS") {
            _alertSnackbar.showErrorAlert(
                "That ${isUncomment == true ? "Uncomment" : "Comment"} didnt register. Try Again.",
                innerContext);
          } else {
            await analyticsController?.sendAnalyticsEvent('comment-made', {
              "commentee": widget.id,
              "commented": authController?.myAppUser?.userId
            });
            List<Comment> theComments = await _getProfileComments();

            setState(() {
              // _isCommenting = false;
              _profileComments = theComments;
            });
            _alertSnackbar.showSuccessAlert(
                "That ${isUncomment == true ? "Uncomment" : "Comment"} ",
                innerContext);
          }
        },
        profileLikedByMe: _profileLikedByMe,
        profileFollowedByMe: _profileFollowedByMe,
      ),
      CommentsTab(
        key: ObjectKey(_profileComments),
        id: widget.id,
        profileComments: _profileComments,
        thisProfile: widget.thisProfile,
        updateComments: (innerContext, String updateCommentResponse) async {

          if (updateCommentResponse != "SUCCESS") {
            _alertSnackbar.showErrorAlert(
                "That like didnt register. Try Again.", innerContext);
          } else {
            List<Comment> theComments =
              await profileClient?.getProfileComments(widget.id) ?? [];
          setState(() {
            _profileComments = theComments;
          });
            _alertSnackbar.showSuccessAlert("Comment Posted.", innerContext);
          }
        },
        isThisMe: _isThisMe,
      ),
      FollowsTab(
        thisProfile: widget.thisProfile,
        isThisMe: _isThisMe,
        profileFollowedByMe: _profileFollowedByMe,
        profileFollows: _profileFollows,
        id: widget.id,
      ),
      LikesTab(
        thisProfile: widget.thisProfile,
        isThisMe: _isThisMe,
        profileLikedByMe: _profileLikedByMe,
        profileLikes: _profileLikes,
        id: widget.id,
      ),
      const Text(
        'Index 3: Photo',
        style: optionStyle,
      ),
    ];

    return theOptions.elementAt(selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppMenu(updateMenu: _onItemTapped),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        // Here we take the value from the LoginPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Logo(),
      ),
      // body: Center(child: Text("just text")),
      body: Center(
        key: Key(_selectedIndex.toString()),
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(child: _widgetOptions(_selectedIndex)),
          ],
        ),
      ),
    );
  }
}
