import 'package:cookout/models/controllers/analytics_controller.dart';
import 'package:cookout/models/post.dart';
import 'package:cookout/shared_components/posts/post_solo.dart';
import 'package:cookout/wrappers/loading_button.dart';
import 'package:flutter/material.dart';

class PostThread extends StatelessWidget {
  const PostThread({super.key, required this.posts, this.analyticsController});

  final AnalyticsController? analyticsController;
  final List<Post> posts;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return posts.length > 0
        ? ListView(
            children: (posts).map((post) {
              return Column(
                children: [PostSolo(post: post), const Divider()],
              );
            }).toList(),
          )
        : Flex(direction: Axis.vertical, children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("There are no posts yet."),
                    SizedBox(
                      height: 16,
                    ),
                    LoadingButton(
                      text: "Add a Post",
                      action: () async {
                        await analyticsController?.sendAnalyticsEvent('add-the-very-first-post', {'frequency_of_event':"once_in_app_history"});
                        Navigator.pushNamed(
                          context,
                          '/createPost',
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ]);
  }
}
