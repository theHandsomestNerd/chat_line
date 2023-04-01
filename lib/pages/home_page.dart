import 'package:cookout/config/api_options.dart';
import 'package:cookout/layout/full_page_layout.dart';
import 'package:cookout/models/extended_profile.dart';
import 'package:cookout/models/post.dart';
import 'package:cookout/sanity/image_url_builder.dart';
import 'package:cookout/shared_components/menus/home_page_menu.dart';
import 'package:cookout/shared_components/menus/login_menu.dart';
import 'package:cookout/wrappers/card_with_actions.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/controllers/auth_inherited.dart';
import '../shared_components/logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.isUserLoggedIn,
  });

  final bool? isUserLoggedIn;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Post? highlightedPost;
  AppUser? highlightedProfile;
  ExtendedProfile? highlightedExtProfile;
  bool isPostLoading = false;
  bool isProfileLoading = false;
  bool isExtProfileLoading = false;
  bool isUserLoggedIn = false;

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theAuthController = AuthInherited.of(context)?.authController;
    var theChatController = AuthInherited.of(context)?.chatController;
    var thePostController = AuthInherited.of(context)?.postController;

    isUserLoggedIn = theAuthController?.isLoggedIn ?? false;
    if (isPostLoading != true && highlightedPost == null) {
      setState(() {
        isPostLoading = true;
      });

      thePostController?.fetchHighlightedPost().then((thePost) {
        if (thePost != null) {
          highlightedPost = thePost;
        }
        setState(() {
          isPostLoading = false;
        });
      });
    }
    if (isProfileLoading != true && highlightedProfile == null) {
      setState(() {
        isProfileLoading = true;
      });
      theChatController?.fetchHighlightedProfile().then((theProfile) {
        setState(() {
          highlightedProfile = theProfile;
          isProfileLoading = false;
        });
      });
    }

    if (isExtProfileLoading != true && highlightedExtProfile == null) {
      setState(() {
        isExtProfileLoading = true;
      });
      theChatController?.profileClient
          .getExtendedProfile(highlightedProfile?.userId ?? "")
          .then((theProfile) {
        setState(() {
          highlightedExtProfile = theProfile;
          isExtProfileLoading = false;
        });
      });
    }
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
      body: FullPageLayout(
        child: Flex(
          direction: Axis.vertical,
          children: [
            highlightedProfile != null
                ? Expanded(
                    child: CardWithActions(
                      locationRow: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                "${highlightedExtProfile?.age ?? "99"} yrs",
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
                                  "${highlightedExtProfile?.height?.feet ?? "9"}' ${highlightedExtProfile?.height?.inches ?? "9"}\"",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.merge(
                                        TextStyle(
                                            color:
                                                Colors.white.withOpacity(.85)),
                                      )),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                "${highlightedExtProfile?.weight ?? "999"} lbs",
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
                      image: highlightedProfile?.profileImage != null
                          ? NetworkImage(MyImageBuilder()
                              .urlFor(highlightedProfile?.profileImage!)!
                              .url())
                          : NetworkImage(
                              DefaultAppOptions.currentPlatform.blankUrl),
                      action1Text:
                          "${highlightedProfile?.displayName?.toUpperCase()[0]}${highlightedProfile?.displayName?.substring(1).toLowerCase()}",
                      action2Text: 'All Profiles',
                      action1OnPressed: () {
                        if (highlightedProfile?.userId != null) {
                          Navigator.pushNamed(context, '/profile',
                              arguments: {"id": highlightedProfile?.userId});
                        }
                      },
                      action2OnPressed: () {
                        Navigator.pushNamed(context, '/profilesPage');
                      },
                    ),
                  )
                : const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            highlightedPost != null && !isPostLoading
                ? Expanded(
                    child: CardWithActions(
                      author: highlightedPost?.author,
                      authorImageUrl: MyImageBuilder()
                              .urlFor(highlightedPost?.author?.profileImage)
                              ?.url() ??
                          "",
                      when: highlightedPost?.publishedAt,
                      locationRow: null,
                      caption: "${highlightedPost?.body}",
                      image: highlightedPost?.mainImage != null
                          ? NetworkImage(MyImageBuilder()
                              .urlFor(highlightedPost?.mainImage!)!
                              .url())
                          : NetworkImage(
                              DefaultAppOptions.currentPlatform.blankUrl),
                      action1Text: highlightedPost?.author?.displayName,
                      action2Text: 'All Posts',
                      action1OnPressed: () {
                        if (highlightedPost?.id != null) {
                          Navigator.pushNamed(context, '/post',
                              arguments: {"id": highlightedPost?.id});
                        }
                      },
                      action2OnPressed: () {
                        Navigator.pushNamed(context, '/postsPage');
                      },
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isPostLoading) CircularProgressIndicator(),
                          if (!isPostLoading)
                            const Text("No Posts with images"),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
