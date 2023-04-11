import 'package:cookout/config/default_config.dart';
import 'package:flutter/material.dart';

import '../../models/clients/bug_report_client.dart';
import '../../platform_dependent/image_uploader_abstract.dart';
import '../../platform_dependent/image_uploader.dart'
    if (dart.library.io) '../../platform_dependent/image_uploader_io.dart'
    if (dart.library.html) '../../platform_dependent/image_uploader_html.dart';
import '../../wrappers/loading_button.dart';
import '../../wrappers/text_field_wrapped.dart';
import '../app_image_uploader.dart';

class BugReporterContent extends StatefulWidget {
  const BugReporterContent({Key? key}) : super(key: key);

  @override
  State<BugReporterContent> createState() => _BugReporterContentState();
}

var INITIAL_DESCRIPTION =
    "What's the issue?\n\nWhat was supposed to happen?\n\n---\n‼️ Note\nLonger description or images help debugging.";

class _BugReporterContentState extends State<BugReporterContent> {
  String _title = "";
  String _description = INITIAL_DESCRIPTION;
  late ImageUploader? imageUploader = ImageUploaderImpl();
  late bool isSubmitting = false;

  submitBug() async {
    setState(() {
      isSubmitting = true;
    });

    await BugReportClient().submitBugReport(_title ?? "", _description ?? "",
        imageUploader?.file?.name ?? "", imageUploader?.file?.bytes, context);
    setState(() {
      isSubmitting = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // key: ObjectKey(isSubmitting),
      backgroundColor: Colors.green,
      title: const Text('Report a Bug'),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LoadingButton(
              isLoading: isSubmitting,
              isDisabled: _title.isEmpty &&
                  _description == INITIAL_DESCRIPTION &&
                  imageUploader?.file?.name == null,
              width: 110,
              action: (x) async {
                await submitBug();
                setState(() {});
                // Navigator.of(context).pop();
              },
              text: "Submit Bug",
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LoadingButton(
              width: 110,
              action: (innerContext) {
                Navigator.of(context).pop();
              },
              text: 'Cancel',
            ),
          ],
        ),
      ],
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 600,
          minWidth: 400,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  TextFieldWrapped(
                    borderColor: Colors.black,
                    initialValue: _title,
                    setField: (value) {
                      _title = value;
                      setState(() {});
                    },
                    labelText: "Title",
                  ),
                  TextFieldWrapped(
                    maxLines: 10,
                    initialValue: _description,
                    setField: (value) {
                      _description = value;
                      setState(() {});
                    },
                    labelText: "Description",
                  ),
                  if (imageUploader != null)
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: AppImageUploader(
                        hideInfo: true,
                        height: 200,
                        width: 200,
                        text: "Photo",
                        imageUploader: imageUploader!,
                        uploadImage: (uploader) {
                          imageUploader = uploader;
                        },
                      ),
                    ),
                  Column(
                    children: [
                      Text(
                          "ui v${DefaultConfig.version}.${DefaultConfig.buildNumber} - ${DefaultConfig.sanityDB}", style: Theme.of(context).textTheme.bodySmall,),
                      Text("v${DefaultConfig.apiVersion}", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            if (isSubmitting)
              Center(
                child: SizedBox(
                    height: 48,
                    width: 200,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black,
                            border: Border.all(
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: Center(
                          child: Text(
                            "Thank you!",
                            style: TextStyle(color: Colors.white),
                          ),
                        ))),
              ),
          ],
        ),
      ),
    );
  }
}
