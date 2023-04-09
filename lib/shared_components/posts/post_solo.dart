import 'package:cookout/sanity/sanity_image_builder.dart';
import 'package:cookout/shared_components/user_block_text.dart';
import 'package:cookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/post.dart';

const POST_IMAGE_SQUARE_SIZE = 400;

class PostSolo extends StatelessWidget {
  const PostSolo({
    super.key,
    required this.post,
  });

  final Post post;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserBlockText(user: post.author),
            ConstrainedBox(
              constraints: const BoxConstraints(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(38, 0, 0, 0),
                child: Column(
                  children: [
                    if (post.mainImage != null)
                      SizedBox(
                        height: POST_IMAGE_SQUARE_SIZE as double,
                        width: POST_IMAGE_SQUARE_SIZE as double,
                        child: CardWithBackground(
                          image: SanityImageBuilder.imageProviderFor(
                                  sanityImage: post.mainImage,
                                  showDefaultImage: true)
                              .image,
                          child: const Text(""),
                        ),
                      ),
                    Text("${post.body}"),
                    Text((post.publishedAt != null
                        ? timeago.format(post.publishedAt!)
                        : "Forever and a day ago")),
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
