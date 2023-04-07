import 'package:cookout/models/clients/api_client.dart';
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
  });

  @override
  State<ProfileGrid> createState() => _ProfileGridState();
}

class _ProfileGridState extends State<ProfileGrid> {
  static const _pageSize = 20;
  AuthController? authController = null;
  late ApiClient client;

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();

    // var theChatController = AuthInherited.of(context)?.chatController;
    var theAuthController = AuthInherited.of(context)?.authController;
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
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

  final PagingController<String, AppUser> _pagingController =
      PagingController(firstPageKey: "");

  Future<void> _fetchPage(String pageKey) async {
    print("Retrieving page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<AppUser>? newItems;
      newItems = await client.fetchProfilesPaginated(pageKey, _pageSize);

      print("Got more items ${newItems.length}");
      final isLastPage = (newItems.length ?? 0) < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems ?? []);
      } else {
        final nextPageKey = newItems.last.userId;
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

    _pagingController.refresh();

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 900,
      height: 900,
      child: PagedGridView<String, AppUser>(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 100,
          crossAxisCount: 4,
          childAspectRatio: 0.5,
        ),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<AppUser>(
          itemBuilder: (context, item, index) => Flex(
            direction: Axis.horizontal,
            children: [Flexible(
              child: ProfileSolo(
                profile: item,
              ),
            ),]
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
