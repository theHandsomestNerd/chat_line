import 'dart:async';

import 'package:cookowt/models/clients/api_client.dart';
import 'package:cookowt/models/controllers/chat_controller.dart';
import 'package:cookowt/models/controllers/geolocation_controller.dart';
import 'package:cookowt/models/extended_profile.dart';
import 'package:cookowt/models/post.dart';
import 'package:cookowt/pages/splash_screen.dart';
import 'package:cookowt/sanity/sanity_image_builder.dart';
import 'package:cookowt/shared_components/loading_logo.dart';
import 'package:cookowt/shared_components/menus/home_page_menu.dart';
import 'package:cookowt/wrappers/app_scaffold_wrapper.dart';
import 'package:cookowt/wrappers/card_with_actions.dart';
import 'package:cookowt/wrappers/circular_progress_indicator_with_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/app_user.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/position.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.isUserLoggedIn});

  final bool? isUserLoggedIn;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  bool isPostLoading = true;
  bool isProfileLoading = true;
  bool isExtProfileLoading = false;
  bool isPositionLoading = false;
  bool isUserLoggedIn = false;
  List<ExtendedProfile> extProfiles = [];
  List<SanityPosition> positions = [];

  final PagingController<String, AppUser> _profilePagingController =
      PagingController(firstPageKey: "");
  final PagingController<String, Post> _postPagingController =
      PagingController(firstPageKey: "");

  static const _pageSize = 5;
  ApiClient? client;

  final _profilePageController = PageController(
    initialPage: 0,
  );
  final _postPageController = PageController(
    initialPage: 0,
  );

  Timer? _profileTimer;
  Timer? _postTimer;

  Future<void> _fetchProfilesPage(String pageKey) async {
    // print("Retrieving page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<AppUser>? newItems;
      newItems = await client?.fetchProfilesPaginated(pageKey, _pageSize) ?? [];

      // print("Got more items ${newItems.length}");
      final isLastPage = (newItems.length) < _pageSize;
      if (isLastPage) {
        if (_profilePageController != null) {
          _profilePagingController.appendLastPage(newItems);
        }
      } else {
        final nextPageKey = newItems.last.userId;
        if (nextPageKey != null) {
          if (_profilePageController != null) {
            _profilePagingController.appendPage(newItems, nextPageKey);
          }
        }
      }
    } catch (error) {
      if (_postPagingController != null) {
        // _profilePagingController.error = error;
      }
    }
  }

  Future<void> _fetchPostsPage(String pageKey) async {
    // print(
    //     "Retrieving posts page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<Post>? newItems;
      newItems = await client?.fetchPostsPaginated(pageKey, _pageSize) ?? [];

      // print("Got more post items ${newItems.length}");
      final isLastPage = (newItems.length) < _pageSize;
      if (isLastPage) {
        _postPagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.id;
        if (nextPageKey != null) {
          _postPagingController.appendPage(newItems, nextPageKey);
        }
      }
    } catch (error) {
      if (_postPagingController != null) _postPagingController.error = error;
    }
  }

  startHomeScreenTimers() async {
    _profileTimer ??= Timer.periodic(const Duration(seconds: 6), (timer) async {
      // print("Timer went off $timer");

      // print(
      //     "There are ${_profilePagingController.itemList?.length} items in the list we on ${_profilePageController.page}");
      // move to next page in profile paging
      _profilePageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: const ElasticInCurve());
    });

    _postTimer ??= Timer.periodic(const Duration(seconds: 18), (timer) async {
      // print("Timer went off $timer");

      _postPageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: const ElasticInCurve());
    });
  }

  profilePagingControllerLocationListener() {
    if (_profilePagingController.itemList != null) {
      isPositionLoading = false;
      setState(() {});
    }
    var profileIndex = _profilePageController.page?.round() ?? 0;
    if (_profilePagingController.itemList != null &&
        _profilePageController.page?.round() == profileIndex) {
      // print(
      //     "$profileIndex ${_profilePageController.page} ${profileIndex == _profilePageController.page}");
      // highlightedProfile = _profilePagingController.itemList![profileIndex];
      SanityPosition? foundLastPosition;
      //get the ext profile
      for (var element in positions) {
        // print(
        //     "${element.userId == _profilePagingController.itemList![profileIndex].userId} ${element.userId} ${_profilePagingController.itemList![profileIndex].userId}");
        if (element.userRef?.userId ==
            _profilePagingController.itemList![profileIndex].userId) {
          foundLastPosition = element;
        }
      }
      if (profileIndex < (_profilePagingController.itemList?.length ?? 0) &&
          foundLastPosition == null &&
          !isPositionLoading) {
        setState(() {
          isPositionLoading = true;
        });
        client
            ?.getLastPosition(
                _profilePagingController.itemList![profileIndex].userId ?? "")
            .then((thePosition) {
          if (thePosition != null) {
            if (kDebugMode) {
              print("remove user position $foundLastPosition");
            }
            if (kDebugMode) {
              print("got user position $thePosition");
            }
            positions.remove(foundLastPosition);
            positions.add(thePosition);
            // setState(() {
            isPositionLoading = false;
            // });
          }

          // highlightedExtProfile = theProfile;
          // setState(() {});
        });
      }
    }
  }

  profilePagingControllerExtProfileListener() {
    if (_profilePagingController.itemList != null) {
      isProfileLoading = false;
      setState(() {});
    }
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
      if (profileIndex < (_profilePagingController.itemList?.length ?? 0) &&
          foundExtProfile == null &&
          !isExtProfileLoading) {
        setState(() {
          isExtProfileLoading = true;
        });
        client
            ?.getExtendedProfile(
                _profilePagingController.itemList![profileIndex].userId ?? "")
            .then((theProfile) {
          if (theProfile != null) {
            extProfiles.add(theProfile);
          }

          // highlightedExtProfile = theProfile;
          setState(() {
            isExtProfileLoading = false;
          });
          // setState(() {});
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    startHomeScreenTimers();

    _profilePagingController.addPageRequestListener((theLastId) async {
      return _fetchProfilesPage(theLastId);
    });
    _postPagingController.addPageRequestListener((theLastId) async {
      return _fetchPostsPage(theLastId);
    });

    _profilePageController
        .addListener(profilePagingControllerExtProfileListener);

    _profilePageController.addListener(profilePagingControllerLocationListener);

    super.initState();
  }

  @override
  void didPushNext() {
    if (kDebugMode) {
      print("router status: didPushnext");
    }
    cancelHomeScreenTimers();
    super.didPushNext();
  }

  @override
  void didPush() {
    if (kDebugMode) {
      print("router status: didPush");
    }
    super.didPush();

    startHomeScreenTimers();
  }

  cancelHomeScreenTimers() {
    _postTimer?.cancel();
    _profileTimer?.cancel();
  }

  @override
  void didPopNext() {
    if (kDebugMode) {
      print("router status: didPopnext");
    }
    super.didPopNext();
    startHomeScreenTimers();
  }

  @override
  void didPop() async {
    if (kDebugMode) {
      print("router status: didPop");
    }
    cancelHomeScreenTimers();
    super.didPop();
  }

  @override
  void dispose() async {
    routeObserver.unsubscribe(this);
    cancelHomeScreenTimers();
    _profilePageController
        .removeListener(profilePagingControllerExtProfileListener);
    _profilePageController
        .removeListener(profilePagingControllerLocationListener);
    _postPageController.dispose();
    _profilePagingController.dispose();
    _postPagingController.dispose();
    _profilePageController.dispose();
    super.dispose();
  }

  ChatController? chatController;
  AnalyticsController? analyticsController;
  GeolocationController? geolocationController;

  @override
  didChangeDependencies() async {
    // startHomeScreenTimers();

    // _postPagingController
    //     .notifyPageRequestListeners("");
    // _profilePagingController
    //     .notifyPageRequestListeners("");

    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);

    var theAuthController = AuthInherited.of(context)?.authController;
    var theChatController = AuthInherited.of(context)?.chatController;
    var theGeoController = AuthInherited.of(context)?.geolocationController;
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
    if (theGeoController == null && theGeoController != null) {
      geolocationController = theGeoController;
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
    // _postPageController.nextPage(
    //     duration: Duration(milliseconds: 500), curve: ElasticInCurve());
    // _profilePageController.nextPage(
    //     duration: Duration(milliseconds: 500), curve: ElasticInCurve());
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return AppScaffoldWrapper(
      floatingActionMenu: HomePageMenu(
        updateMenu: () => {},
      ),
      child: Container(
        color: Colors.white,
        child: Flex(
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
                childrenDelegate: SliverChildBuilderDelegate(
                  (build, thePageIndex) {
                    var theItem =
                        _profilePagingController.itemList?.isNotEmpty ?? false
                            ? _profilePagingController.itemList![thePageIndex]
                            : null;

                    if (thePageIndex >=
                        (_profilePagingController.itemList?.length ?? 0) - 3) {
                      _profilePagingController.notifyPageRequestListeners(
                          _profilePagingController.nextPageKey ?? "");
                    }

                    ExtendedProfile? thisExtProfile;
                    for (var element in extProfiles) {
                      if (element.userId ==
                          _profilePagingController
                              .itemList![thePageIndex].userId) {
                        thisExtProfile = element;
                      }
                    }

                    SanityPosition? thisUserPosition;
                    for (var element in positions) {
                      if (element.userRef?.userId ==
                          _profilePagingController
                              .itemList![thePageIndex].userId) {
                        thisUserPosition = element;
                      }
                    }

                    //get the extended profile for this user
                    return theItem != null
                        ? GestureDetector(
                            onTap: () async {
                              if (theItem.userId != null) {
                                cancelHomeScreenTimers();
                                await analyticsController?.sendAnalyticsEvent(
                                    'view-profile-while-highlighted-pressed', {
                                  "highlightedUserId": theItem.userId
                                }).then((x) {
                                  GoRouter.of(context)
                                      .go('/profile/${theItem.userId}');

                                  // Navigator.pushNamed(context, '/profile',
                                  //     arguments: {"id": theItem.userId});
                                });
                              }
                            },
                            onPanUpdate: (details) async {
                              // Swiping in up direction.
                              if (details.delta.dy < 0) {
                                cancelHomeScreenTimers();
                                await analyticsController?.sendAnalyticsEvent(
                                    'view-all-profiles-pressed', {
                                  "highlightedUserId": theItem.userId
                                }).then((x) {
                                  GoRouter.of(context).go('/profilesPage');

                                  // Navigator.pushNamed(context, '/profilesPage');
                                });
                              }

                              // Swiping in down direction.
                              if (details.delta.dy > 0) {
                                if (kDebugMode) {
                                  print('swipe down');
                                }
                              }
                            },
                            child: CardWithActions(
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
                                                  color: Colors.white
                                                      .withOpacity(.85)),
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
                                                    color: Colors.white
                                                        .withOpacity(.85)),
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
                                                  color: Colors.white
                                                      .withOpacity(.85)),
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
                                        Text(
                                          "${GeolocationController.distanceBetween(GeolocationController.theCurrentPosition, thisUserPosition).toString()} mi.",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              image: SanityImageBuilder.imageProviderFor(
                                      sanityImage: theItem.profileImage,
                                      showDefaultImage: true)
                                  .image,
                              // action1Text:
                              //     "${theItem.displayName?.toUpperCase()[0]}${theItem.displayName?.substring(1).toLowerCase()}",
                              action1Text: 'All Profiles',
                              // action1OnPressed: () async {
                              // if (theItem.userId != null) {
                              //   cancelHomeScreenTimers();
                              //   await analyticsController?.sendAnalyticsEvent(
                              //       'view-profile-while-highlighted-pressed', {
                              //     "highlightedUserId": theItem.userId
                              //   }).then((x) {
                              //     Navigator.pushNamed(context, '/profile',
                              //         arguments: {"id": theItem.userId});
                              //   });
                              // }
                              // },
                              action1OnPressed: () async {
                                cancelHomeScreenTimers();
                                await analyticsController?.sendAnalyticsEvent(
                                    'view-all-profiles-pressed', {
                                  "highlightedUserId": theItem.userId
                                }).then((x) {
                                  GoRouter.of(context).go('/profilesPage');

                                  // Navigator.pushNamed(context, '/profilesPage');
                                });
                              },
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                !isProfileLoading && (theItem != null)
                                    ? const Text("No Profiles with images")
                                    : Column(
                                        children: [
                                          LoadingLogo(),
                                          Text("Loading Profile Previews")
                                        ],
                                      ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
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

                childrenDelegate: SliverChildBuilderDelegate(
                  (build, thePageIndex) {
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
                    return theItem != null
                        ? GestureDetector(
                            onTap: () async {
                              cancelHomeScreenTimers();
                              await analyticsController?.sendAnalyticsEvent(
                                  'view-post-while-highlighted-pressed',
                                  {"highlightedPostId": theItem.id}).then((x) {
                                if (theItem.id != null) {
                                  GoRouter.of(context).go('/post/${theItem.id}');

                                  // Navigator.pushNamed(context, '/post',
                                  //     arguments: {"id": theItem.id});
                                }
                              });
                            },
                            onPanUpdate: (details) async {
                              // Swiping in up direction.
                              if (details.delta.dy < 0) {
                                if (kDebugMode) {
                                  print('swipe upswipe up');
                                }
                                cancelHomeScreenTimers();
                                await analyticsController?.sendAnalyticsEvent(
                                    'view-all-posts-while-highlighted-pressed',
                                    {"highlightedPostId": theItem.id}).then((x) {
                                  GoRouter.of(context).go('/postsPage');

                                  // Navigator.pushNamed(context, '/postsPage');
                                });
                              }

                              // Swiping in down direction.
                              if (details.delta.dy > 0) {
                                if (kDebugMode) {
                                  print('swipe down');
                                }
                              }
                            },
                            child: CardWithActions(
                              author: theItem.author,
                              when: theItem.publishedAt,
                              locationRow: null,
                              caption: theItem.body,
                              image: SanityImageBuilder.imageProviderFor(
                                      sanityImage: theItem.mainImage,
                                      showDefaultImage: true)
                                  .image,
                              action1Text: 'All Posts',
                              action1OnPressed: () async {
                                cancelHomeScreenTimers();
                                await analyticsController?.sendAnalyticsEvent(
                                    'view-all-posts-while-highlighted-pressed',
                                    {"highlightedPostId": theItem.id}).then((x) {
                                  GoRouter.of(context).go('/postsPage');

                                  // Navigator.pushNamed(context, '/postsPage');
                                });
                              },
                              // action2Text: 'Go to post',
                              // action2OnPressed: () async {
                              //   cancelHomeScreenTimers();
                              //   await analyticsController?.sendAnalyticsEvent(
                              //       'view-post-while-highlighted-pressed',
                              //       {"highlightedPostId": theItem.id}).then((x) {
                              //     if (theItem.id != null) {
                              //       Navigator.pushNamed(context, '/post',
                              //           arguments: {"id": theItem.id});
                              //     }
                              //   });
                              // },
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                !isPostLoading && (theItem == null)
                                    ? const Text("No Posts with images")
                                    : Column(
                                  children: [
                                    LoadingLogo(),
                                    Text("Loading Post Previews")
                                  ],
                                ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
