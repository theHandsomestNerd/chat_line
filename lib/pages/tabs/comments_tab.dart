import 'package:cookowt/layout/list_and_small_form.dart';
import 'package:cookowt/models/controllers/chat_controller.dart';
import 'package:cookowt/shared_components/comments/comment_thread.dart';
import 'package:cookowt/wrappers/analytics_loading_button.dart';
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
  final Function updateComments;

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  ChatController? chatController;
  String? _commentBody;
  bool isCommenting = false;
  List<Comment> _comments = [];

  @override
  initState() {
    super.initState();

    _comments = widget.profileComments ?? [];
  }

  @override
  didChangeDependencies() async {
    var theChatController = AuthInherited.of(context)?.chatController;
    _comments =
        await theChatController?.profileClient.getProfileComments(widget.id, 'profile-comment') ??
            [];
    chatController = theChatController;

    setState(() {});
    super.didChangeDependencies();
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
        .commentDocument(widget.id, _commentBody ?? "", 'profile-comment');

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
          AnalyticsLoadingButton(
            isDisabled: isCommenting,
            analyticsEventName: 'create-comment',
            analyticsEventData: {'author': widget.id, "body":_commentBody},
            action: (innercontext) async {
              await _commentThisProfile(innercontext);
            },
            text: "Comment",
          )
        ],
      ),
    );
  }
}
