import 'package:kookout/shared_components/menus/home_page_menu.dart';
import 'package:kookout/wrappers/app_scaffold_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/clients/api_client.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/post.dart';
import '../shared_components/posts/post_solo.dart';
import '../wrappers/analytics_loading_button.dart';
import 'create_post_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({
    super.key,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final PagingController<String, Post> _pagingController =
      PagingController(firstPageKey: "");
  AuthController? authController;
  PanelController panelController = PanelController();
  late ApiClient client;
  AnalyticsController? analyticsController;
  bool isPanelOpen = false;

  static const _pageSize = 10;
  String lastId = "";

  @override
  void initState() {
    _pagingController.addPageRequestListener((theLastId) async {
      return _fetchPage(theLastId);
    });

    super.initState();
  }


  @override
  didChangeDependencies() async {

    // var theChatController = AuthInherited.of(context)?.chatController;
    var theAuthController = AuthInherited.of(context)?.authController;
    var theAnalyticsController = AuthInherited.of(context)?.analyticsController;
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
    }

    if (theAnalyticsController != null && analyticsController == null) {
      analyticsController = theAnalyticsController;
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
    super.didChangeDependencies();
  }

  Future<void> _fetchPage(String pageKey) async {
    // print(
    //     "Retrieving post page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<Post>? newItems;
      newItems = await client.fetchPostsPaginated(pageKey, _pageSize);

      // print("Got more items ${newItems.length}");
      final isLastPage = (newItems.length) < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.id;
        if (nextPageKey != null) {
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
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
        updateMenu: () {},
      ),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: Colors.black87),
                ),
                PagedListView<String, Post>(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    56,
                  ),
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Post>(
                    noItemsFoundIndicatorBuilder: (build) {
                      return Flex(direction: Axis.horizontal, children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 500),
                            child: Flex(
                              direction: Axis.vertical,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("There are no posts yet."),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        AnalyticsLoadingButton(
                                          analyticsEventData: const {
                                            'frequency_of_event':
                                                "once_in_app_history"
                                          },
                                          analyticsEventName:
                                              'add-the-very-first-post',
                                          text: "Add a Post",
                                          action: (context) async {
                                            panelController.open();

                                            // Navigator.pushNamed(
                                            //   context,
                                            //   '/createPostsPage',
                                            // );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]);
                    },
                    itemBuilder: (context, item, index) => Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                      child: PostSolo(
                        post: item,
                      ),
                    ),
                  ),
                ),
                SlidingUpPanel(
                  onPanelClosed: () {
                    isPanelOpen = false;
                  },
                  onPanelOpened: () {
                    isPanelOpen = true;
                  },
                  collapsed: MaterialButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    color: Colors.red,
                    onPressed: () {
                      if (isPanelOpen) {
                        panelController.close();
                        // isPanelOpen = false;
                      } else {
                        panelController.open();
                        // isPanelOpen = true;
                      }
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            8.0,
                            8.0,
                            8.0,
                            16.0,
                          ),
                          child: Container(
                            color: Colors.white,
                            width: 80,
                            height: 3,
                          ),
                        ),
                        const Text(
                          "Create a Post",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  controller: panelController,
                  backdropEnabled: true,
                  isDraggable: true,
                  parallaxEnabled: false,
                  maxHeight: 500,
                  color: Colors.transparent,
                  minHeight: 64,
                  panelBuilder: (scrollController) => SingleChildScrollView(
                    // controller: scrollController,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(0),
                              bottomLeft: Radius.circular(0))),
                      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          // MaterialButton(
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.all(Radius.circular(20)),
                          //   ),
                          //   color: Colors.white,
                          //   onPressed: () {
                          //     panelController.close();
                          //   },
                          //   child: Flex(
                          //     direction: Axis.vertical,
                          //     children: [
                          //       Flexible(
                          //         flex: 1,
                          //         child: Padding(
                          //           padding: const EdgeInsets.fromLTRB(
                          //             8.0,
                          //             8.0,
                          //             8.0,
                          //             8.0,
                          //           ),
                          //           child: Container(
                          //             color: Colors.white,
                          //             width: 80,
                          //             height: 3,
                          //           ),
                          //         ),
                          //       ),
                          //       Expanded(
                          //         flex: 2,
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             Text(
                          //               "Create a Post",
                          //               style: TextStyle(color: Colors.black, fontSize: 18),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 48,
                                  child: Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Expanded(
                                          child: MaterialButton(
                                            elevation: 0,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              panelController.hide();
                                            },
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                    8.0,
                                                    8.0,
                                                    8.0,
                                                    8.0,
                                                  ),
                                                  child: Container(
                                                    color: Colors.black,
                                                    width: 80,
                                                    height: 3,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Text(
                                                      "Create a Post",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                                CreatePostPage(
                                  onPost: () {
                                    panelController.close();
                                    _pagingController.refresh();
                                    _fetchPage(_pagingController.firstPageKey);
                                    // _pagingController.firstPageKey
                                  },
                                  onClose: () {
                                    panelController.close();
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(
                                  height: 24,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
