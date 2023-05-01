import 'package:cookowt/models/controllers/chat_controller.dart';
import 'package:cookowt/shared_components/tool_button.dart';
import 'package:cookowt/shared_components/user_block_text.dart';
import 'package:cookowt/wrappers/alerts_snackbar.dart';
import 'package:flutter/material.dart';

import '../../models/block.dart';
import '../../models/controllers/auth_inherited.dart';

class BlockSolo extends StatefulWidget {
  const BlockSolo({
    super.key,
    required this.block,
    required this.unblockProfile,
  });

  final Block block;
  final Function unblockProfile;

  @override
  State<BlockSolo> createState() => _BlockSoloState();
}

class _BlockSoloState extends State<BlockSolo> {
  late ChatController? chatController;

  @override
  didChangeDependencies() async {
    var theChatController = AuthInherited.of(context)?.chatController;
    chatController = theChatController;
    setState(() {});
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Expanded(
            flex: 1,
            child: Center(
              child: Icon(
                Icons.block,
                size: 24.0,
                semanticLabel: 'Blocks',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: UserBlockText(
              user: widget.block.blocked,
            ),
          ),
          Expanded(
            flex: 1,
            child: ToolButton(
              action: (innerContext) async {
                var response =
                    await chatController?.unblockProfile(widget.block);

                if (response == "SUCCESS") {
                  AlertSnackbar()
                      .showSuccessAlert("Unblock succeeded", innerContext);
                } else {
                  AlertSnackbar().showErrorAlert(
                      "Unblock failed. Try again.", innerContext);
                }

                setState(() {});
                await widget.unblockProfile(innerContext);
              },
              iconData: Icons.close,
              color: Colors.grey,
              label: 'unblock',
              isHideLabel: true,
            ),
          ),
        ],
      ),
    );
  }
}
