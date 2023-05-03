import 'package:cookowt/models/comment.dart';
import 'package:cookowt/wrappers/author_and_text.dart';
import 'package:flutter/material.dart';


class CommentThread extends StatelessWidget {
  const CommentThread({
    super.key,
    required this.comments,
  });

  final List<Comment> comments;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...(comments).map((comment) {
          return Column(
            children: [
              if (comment.author != null)
                AuthorAndText(
                  backgroundColor: Colors.white,
                    author: comment.author!,
                    body: comment.commentBody,
                    when: comment.publishedAt),
              const Divider()
            ],
          );
        }).toList()
      ],
    );
  }
}
