import 'dart:async';

import 'package:cookout/layout/full_page_layout.dart';
import 'package:cookout/models/clients/api_client.dart';
import 'package:cookout/models/controllers/chat_controller.dart';
import 'package:cookout/models/extended_profile.dart';
import 'package:cookout/models/post.dart';
import 'package:cookout/sanity/image_url_builder.dart';
import 'package:cookout/shared_components/menus/home_page_menu.dart';
import 'package:cookout/wrappers/card_with_actions.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/app_user.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../shared_components/logo.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.isUserLoggedIn});

  final bool? isUserLoggedIn;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  bool isPostLoading = false;
  bool isProfileLoading = false;
  bool isExtProfileLoading = false;
  bool isUserLoggedIn = false;
  List<ExtendedProfile> extProfiles = [];

  final PagingController<String, AppUser> _profilePagingController =
      PagingController(firstPageKey: "");
  final PagingController<String, Post> _postPagingController =
      PagingController(firstPageKey: "");

  static const _pageSize = 5;
  late ApiClient? client = null;

  final _profilePageController = PageController(
    initialPage: 0,
  );
  final _postPageController = PageController(
    initialPage: 0,
  );

  Timer? profileTimer;
  Timer? postTimer;

  Future<void> _fetchProfilesPage(String pageKey) async {
    print("Retrieving page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<AppUser>? newItems;
      newItems = await client?.fetchProfilesPaginated(pageKey, _pageSize) ?? [];

      print("Got more items ${newItems.length}");
      final isLastPage = (newItems.length ?? 0) < _pageSize;
      if (isLastPage) {
        _profilePagingController.appendLastPage(newItems ?? []);
      } else {
        final nextPageKey = newItems.last.userId;
        if (nextPageKey != null) {
          _profilePagingController.appendPage(newItems ?? [], nextPageKey);
        }
      }
    } catch (error) {
      _profilePagingController.error = error;
    }
  }

  Future<void> _fetchPostsPage(String pageKey) async {
    print(
        "Retrieving posts page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<Post>? newItems;
      newItems = await client?.fetchPostsPaginated(pageKey, _pageSize) ?? [];

      print("Got more post items ${newItems.length}");
      final isLastPage = (newItems.length ?? 0) < _pageSize;
      if (isLastPage) {
        _postPagingController.appendLastPage(newItems ?? []);
      } else {
        final nextPageKey = newItems.last.id;
        if (nextPageKey != null) {
          _postPagingController.appendPage(newItems ?? [], nextPageKey);
        }
      }
    } catch (error) {
      _postPagingController.error = error;
    }
  }

  startHomeScreenTimers() async {
    profileTimer ??= Timer.periodic(Duration(seconds: 6), (timer) async {
      print("Timer went off $timer");

      print(
          "There are ${_profilePagingController.itemList?.length} items in the list we on ${_profilePageController.page}");
      // move to next page in profile paging
      _profilePageController.nextPage(
          duration: Duration(milliseconds: 500), curve: ElasticInCurve());
    });
    postTimer ??= Timer.periodic(Duration(seconds: 18), (timer) async {
      print("Timer went off $timer");

      _postPageController.nextPage(
          duration: Duration(milliseconds: 500), curve: ElasticInCurve());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _profilePagingController.addPageRequestListener((theLastId) async {
      return _fetchProfilesPage(theLastId);
    });
    _postPagingController.addPageRequestListener((theLastId) async {
      return _fetchPostsPage(theLastId);
    });

    _profilePageController.addListener(() {
      var profileIndex = _profilePageController.page?.round() ?? 0;
      if (_profilePagingController.itemList != null &&
          _profilePageController.page?.round() == profileIndex) {
        // print(
        //     "$profileIndex ${_profilePageController.page} ${profileIndex == _profilePageController.page}");
        // highlightedProfile = _profilePagingController.itemList![profileIndex];
        ExtendedProfile? foundExtProfile;
        //get the ext profile
        for (var element in extProfiles) {
          // print(
          //     "${element.userId == _profilePagingController.itemList![profileIndex].userId} ${element.userId} ${_profilePagingController.itemList![profileIndex].userId}");
          if (element.userId ==
              _profilePagingController.itemList![profileIndex].userId) {
            foundExtProfile = element;
          }
        }
        if (profileIndex < (_profilePagingController.itemList?.length ?? 0) && foundExtProfile == null && !isExtProfileLoading ) {
          setState(() {

          isExtProfileLoading = true;
          });
          client
              ?.getExtendedProfile(
                  _profilePagingController.itemList![profileIndex].userId ?? "")
              .then((theProfile) {
            setState(() {
              if (theProfile != null) {
                extProfiles.add(theProfile);
              }
              // highlightedExtProfile = theProfile;
              isExtProfileLoading = false;
            });
            // setState(() {});
          });
        }
      }
    });

    _profilePagingController.notifyPageRequestListeners("");
    _postPagingController.notifyPageRequestListeners("");

    startHomeScreenTimers();
  }

  @override
  void didPushNext() {
    print("router status: didPushnext");
    cancelHomeScreenTimers();
    super.didPushNext();
  }

  @override
  void didPush() {
    print("router status: didPush");
    super.didPush();

    startHomeScreenTimers();
  }

  cancelHomeScreenTimers() {
    postTimer?.cancel();
    profileTimer?.cancel();
  }

  @override
  void didPopNext() {
    print("router status: didPopnext");
    super.didPopNext();
    startHomeScreenTimers();
  }

  @override
  void didPop() async {
    print("router status: didPop");
    cancelHomeScreenTimers();
    super.didPop();
  }

  @override
  void dispose() async {
    routeObserver.unsubscribe(this);
    cancelHomeScreenTimers();
    _profilePageController.dispose();
    _postPageController.dispose();
    _profilePagingController.dispose();
    _postPagingController.dispose();
    super.dispose();
  }

  late ChatController? chatController = null;
  late AnalyticsController? analyticsController = null;

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    startHomeScreenTimers();

    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);

    var theAuthController = AuthInherited.of(context)?.authController;
    var theChatController = AuthInherited.of(context)?.chatController;
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
    }

    theAnalyticsController?.logScreenView('Home');
    if (analyticsController == null && theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
    }

    if (chatController == null && theChatController != null) {
      chatController = theChatController;
    }
    isUserLoggedIn = theAuthController?.isLoggedIn ?? false;

    // if (isProfileLoading != true && highlightedProfile == null) {
    //   setState(() {
    //     isProfileLoading = true;
    //   });
    //   await theChatController
    //       ?.fetchHighlightedProfile()
    //       .then((theProfile) async {
    //     await analyticsController?.sendAnalyticsEvent(
    //         'highlighted-profile', {"user_id": theProfile?.userId});
    //
    //     setState(() {
    //       highlightedProfile = theProfile;
    //       isProfileLoading = false;
    //     });
    //   });
    // }

    // if (isExtProfileLoading != true && highlightedExtProfile == null) {
    //   setState(() {
    //     isExtProfileLoading = true;
    //   });
    //   await theChatController?.profileClient
    //       .getExtendedProfile(highlightedProfile?.userId ?? "")
    //       .then((theProfile) {
    //     setState(() {
    //       highlightedExtProfile = theProfile;
    //       isExtProfileLoading = false;
    //     });
    //   });
    // }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      floatingActionButton: HomePageMenu(
        updateMenu: () => {},
      ),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5),

        // Here we take the value from the HomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Logo(),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: PageView.custom(
              controller: _profilePageController,
              // pagingController: _pagingController,
              // shrinkWrap: true,
              // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //   mainAxisExtent: 450,
              //   crossAxisCount: 1,
              //   childAspectRatio: 1,
              // ),
              childrenDelegate:
                  SliverChildBuilderDelegate((build, thePageIndex) {
                var theItem =
                    _profilePagingController.itemList?.isNotEmpty ?? false
                        ? _profilePagingController.itemList![thePageIndex]
                        : null;

                if (thePageIndex >=
                    (_profilePagingController.itemList?.length ?? 0) - 3) {
                  _profilePagingController.notifyPageRequestListeners(
                      _profilePagingController.nextPageKey ?? "");
                }

                var thisExtProfile;
                extProfiles.forEach((element) {
                  if (element.userId ==
                      _profilePagingController
                          .itemList![thePageIndex].userId) {
                    thisExtProfile = element;
                  }
                });

                //get the extended profile for this user
                return CardWithActions(
                  locationRow: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            "${thisExtProfile?.age ?? "99"} yrs",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.merge(
                                  TextStyle(
                                      color: Colors.white.withOpacity(.85)),
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                              "${thisExtProfile?.height?.feet ?? "9"}' ${thisExtProfile?.height?.inches ?? "9"}\"",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.merge(
                                    TextStyle(
                                        color: Colors.white.withOpacity(.85)),
                                  )),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            "${thisExtProfile?.weight ?? "999"} lbs",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.merge(
                                  TextStyle(
                                      color: Colors.white.withOpacity(.85)),
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.pin_drop,
                              size: 30.0,
                              color: Colors.white.withOpacity(.8),
                              semanticLabel: "Location",
                            ),
                            const Text(
                              '300 mi.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  image: theItem?.profileImage != null
                      ? NetworkImage(MyImageBuilder()
                          .urlFor(theItem?.profileImage!, null, null)!
                          .url())
                      : Image(
                          image: AssetImage('assets/blankProfileImage.png'),
                        ).image,
                  action1Text:
                      "${theItem?.displayName?.toUpperCase()[0]}${theItem?.displayName?.substring(1).toLowerCase()}",
                  action2Text: 'All Profiles',
                  action1OnPressed: () async {
                    if (theItem?.userId != null) {
                      await analyticsController?.sendAnalyticsEvent(
                          'view-profile-while-highlighted-pressed',
                          {"highlightedUserId": theItem?.userId});
                      cancelHomeScreenTimers();

                      Navigator.pushNamed(context, '/profile',
                          arguments: {"id": theItem?.userId});
                    }
                  },
                  action2OnPressed: () async {
                    await analyticsController?.sendAnalyticsEvent(
                        'view-all-profiles-pressed',
                        {"highlightedUserId": theItem?.userId});

                    cancelHomeScreenTimers();

                    Navigator.pushNamed(context, '/profilesPage');
                  },
                );
              }),
            ),
          )
          // : Expanded(
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           !isPostLoading &&
          //                   (chatController?.profileList.isEmpty ?? false)
          //               ? const Text("No Profiles with images")
          //               : CircularProgressIndicator(),
          //         ],
          //       ),
          //     ),
          //   )
          ,
          Expanded(
            child: PageView.custom(
              controller: _postPageController,
              // pagingController: _pagingController,
              // shrinkWrap: true,
              // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //   mainAxisExtent: 450,
              //   crossAxisCount: 1,
              //   childAspectRatio: 1,
              // ),
              childrenDelegate:
                  SliverChildBuilderDelegate((build, thePageIndex) {
                var theItem =
                    _postPagingController.itemList?.isNotEmpty ?? false
                        ? _postPagingController.itemList![thePageIndex]
                        : null;

                if (thePageIndex >=
                    (_postPagingController.itemList?.length ?? 0) - 3) {
                  _postPagingController.notifyPageRequestListeners(
                      _postPagingController.nextPageKey ?? "");
                }

                //get the extended profile for this user
                return CardWithActions(
                  author: theItem?.author,
                  authorImageUrl: MyImageBuilder()
                          .urlFor(theItem?.author?.profileImage, null, null)
                          ?.url() ??
                      "",
                  when: theItem?.publishedAt,
                  locationRow: null,
                  caption: "${theItem?.body}",
                  image: theItem?.mainImage != null
                      ? NetworkImage(MyImageBuilder()
                          .urlFor(theItem?.mainImage!, null, null)!
                          .url())
                      : Image(
                          image: AssetImage('assets/blankProfileImage.png'),
                        ).image,
                  action1Text: theItem?.author?.displayName,
                  action2Text: 'All Posts',
                  action1OnPressed: () async {
                    await analyticsController?.sendAnalyticsEvent(
                        'view-post-while-highlighted-pressed',
                        {"highlightedPostId": theItem?.id});

                    if (theItem?.id != null) {
                      cancelHomeScreenTimers();
                      Navigator.pushNamed(context, '/post',
                          arguments: {"id": theItem?.id});
                    }
                  },
                  action2OnPressed: () async {
                    await analyticsController?.sendAnalyticsEvent(
                        'view-all-posts-while-highlighted-pressed',
                        {"highlightedPostId": theItem?.id});
                    cancelHomeScreenTimers();
                    Navigator.pushNamed(context, '/postsPage');
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
