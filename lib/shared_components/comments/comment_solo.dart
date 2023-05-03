import 'package:cookowt/shared_components/user_block_text.dart';
import 'package:flutter/material.dart';

import '../../models/comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentSolo extends StatelessWidget {
  const CommentSolo({
    super.key,
    required this.comment,
  });

  final Comment comment;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserBlockText(user: comment.author),
          ConstrainedBox(
            constraints: const BoxConstraints(),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(38, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${comment.commentBody}"),
                    Text((comment.publishedAt != null
                        ? timeago.format(comment.publishedAt!)
                        : "Forever and a day ago")),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
