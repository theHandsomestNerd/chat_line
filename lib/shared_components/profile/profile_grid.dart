import 'package:cookout/models/controllers/auth_controller.dart';
import 'package:cookout/shared_components/profile/profile_solo.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/app_user.dart';
import '../../models/controllers/auth_inherited.dart';
import '../../models/controllers/chat_controller.dart';

class ProfileGrid extends StatefulWidget {
  const ProfileGrid({
    super.key,
    this.profiles,
  });

  final List<AppUser>? profiles;

  @override
  State<ProfileGrid> createState() => _ProfileGridState();
}

class _ProfileGridState extends State<ProfileGrid> {
  static const _pageSize = 20;
  static String? thePageKey = null;
  List<AppUser> profiles = [];
  AuthController? authController;
  ChatController? chatController;

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theChatController = AuthInherited.of(context)?.chatController;
    var theAuthController = AuthInherited.of(context)?.authController;
    var theAAuthClient =
        AuthInherited.of(context)?.chatController?.profileClient;
    // AnalyticsController? theAnalyticsController =
    //     AuthInherited.of(context)?.analyticsController;

    // if(analyticsController == null && theAnalyticsController != null) {
    //   await theAnalyticsController.logScreenView('profiles-page');
    //   analyticsController = theAnalyticsController;
    // }
    if (authController == null && theAuthController != null) {
      authController = authController;
    }
    chatController = theChatController;
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

  final PagingController<String, AppUser> _pagingController =
      PagingController(firstPageKey: "");

  Future<void> _fetchPage(String pageKey) async {
    try {
      List<AppUser>? newItems;
      newItems = await chatController?.profileClient
          .fetchProfilesPaginated(pageKey, _pageSize);

      final isLastPage = (newItems?.length ?? 0) < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems ?? []);
      } else {
        final nextPageKey = newItems?.last.userId;
        if (nextPageKey != null) {
          _pagingController.appendPage(newItems ?? [], nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((theLastId) async {
      return _fetchPage(theLastId);
    });

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 900,
      height: 900,
      child: PagedListView<String, AppUser>(
        scrollDirection: Axis.horizontal,
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<AppUser>(
          itemBuilder: (context, item, index) => ProfileSolo(
            profile: item,
          ),
        ),
      ),
      // child: SingleChildScrollView(
      //   child: Wrap(
      //       children: (widget.profiles ?? []).map((profile) {
      //     return ProfileSolo(
      //       profile: profile,
      //     );
      //   }).toList()),
      // ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
