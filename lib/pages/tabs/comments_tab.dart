import 'package:chat_line/layout/list_and_small_form.dart';
import 'package:chat_line/models/controllers/auth_controller.dart';
import 'package:chat_line/models/controllers/chat_controller.dart';
import 'package:chat_line/shared_components/comments/comment_thread.dart';
import 'package:chat_line/wrappers/loading_button.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/comment.dart';
import '../../models/controllers/auth_inherited.dart';

class CommentsTab extends StatefulWidget {
  const CommentsTab(
      {super.key,
      required this.id,
      required this.profileComments,
      required this.thisProfile,
      required this.updateComments,
      required this.isThisMe});

  final List<Comment>? profileComments;
  final AppUser? thisProfile;
  final String id;
  final bool isThisMe;
  final updateComments;

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  late ChatController? chatController = null;
  late String? _commentBody = null;
  bool isCommenting = false;
  late List<Comment> _comments = [];

  @override
  initState() {
    super.initState();

    _comments = widget.profileComments ?? [];
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theChatController = AuthInherited.of(context)?.chatController;
    _comments =
        await theChatController?.profileClient.getProfileComments(widget.id) ??
            [];
    chatController = theChatController;

    setState(() {});
    print("timeline events dependencies changed ${_comments}");
  }

  void _setCommentBody(String newCommentBody) {
    setState(() {
      _commentBody = newCommentBody;
    });
  }

  _commentThisProfile(context) async {
    setState(() {
      isCommenting = true;
    });
    String? commentResponse;

    commentResponse = await chatController?.profileClient
        .commentProfile(widget.id, _commentBody ?? "");

    await widget.updateComments(context, commentResponse);
    setState(() {
      isCommenting = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListAndSmallFormLayout(
      listChild: CommentThread(
        key: ObjectKey(_comments),
        comments: _comments,
      ),
      formChild: Column(
        children: [
          TextFormField(
            autofocus: true,
            onChanged: (e) {
              _setCommentBody(e);
            },
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Comment:',
            ),
          ),
          LoadingButton(
            action: () {
              _commentThisProfile(context);
            },
            isLoading: isCommenting,
            text: "Comment",
          )
        ],
      ),
    );
  }
}
