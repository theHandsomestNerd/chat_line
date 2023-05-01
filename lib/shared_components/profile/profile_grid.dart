import 'package:cookowt/models/clients/api_client.dart';
import 'package:cookowt/shared_components/profile/profile_solo.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/app_user.dart';
import '../../models/controllers/auth_inherited.dart';

class ProfileGrid extends StatefulWidget {
  const ProfileGrid({
    super.key,
  });

  @override
  State<ProfileGrid> createState() => _ProfileGridState();
}

class _ProfileGridState extends State<ProfileGrid> {
  static const _pageSize = 40;
  late ApiClient client;

  @override
  didChangeDependencies() async {

    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
    }

    setState(() {});
    super.didChangeDependencies();
  }

  final PagingController<String, AppUser> _pagingController =
      PagingController(firstPageKey: "");

  Future<void> _fetchPage(String pageKey) async {
    // print("Retrieving page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<AppUser>? newItems;
      newItems = await client.fetchProfilesPaginated(pageKey, _pageSize);

      // print("Got more items ${newItems.length}");
      final isLastPage = (newItems.length) < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.userId;
        if (nextPageKey != null) {
          _pagingController.appendPage(newItems, nextPageKey);
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
    return PagedGridView<String, AppUser>(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 125,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        crossAxisCount: 4,
      ),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<AppUser>(
        itemBuilder: (context, item, index) =>
            Center(
              child: ProfileSolo(
                profile: item,
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
