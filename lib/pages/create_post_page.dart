import 'package:cookout/layout/full_page_layout.dart';
import 'package:cookout/models/controllers/auth_inherited.dart';
import 'package:cookout/shared_components/menus/posts_page_menu.dart';
import 'package:cookout/wrappers/alerts_snackbar.dart';
import 'package:cookout/wrappers/analytics_loading_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';

import '../../platform_dependent/image_uploader.dart'
    if (dart.library.io) '../../platform_dependent/image_uploader_io.dart'
    if (dart.library.html) '../../platform_dependent/image_uploader_html.dart';
import '../config/default_config.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../models/controllers/post_controller.dart';
import '../platform_dependent/image_uploader_abstract.dart';
import '../shared_components/app_image_uploader.dart';
import '../shared_components/logo.dart';
import '../wrappers/loading_button.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({
    super.key,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final AlertSnackbar _alertSnackbar = AlertSnackbar();

  late ImageUploader? imageUploader;
  AuthController? authController;
  PostController? postController;
  AnalyticsController? analyticsController = null;

  String? _postBody;
  bool? _isPosting;
  var imageToBeUploaded = null;
  late SanityImage? profileImage = null;

  @override
  initState() {
    super.initState();
    imageUploader = ImageUploaderImpl();
    imageToBeUploaded = _getMyProfileImage(null);
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    AuthController? theAuthController =
        AuthInherited.of(context)?.authController;
    authController = theAuthController;
    PostController? thePostController =
        AuthInherited.of(context)?.postController;
    postController = thePostController;

    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    theAnalyticsController?.logScreenView('Create Post');

    analyticsController = theAnalyticsController;

    if (!((_postBody?.length ?? -1) <= 0) && (_postBody?.length ?? 0) < 5) {
      await analyticsController
          ?.sendAnalyticsEvent('post-form-enabled', {"body": _postBody});
    }
    setState(() {});
  }

  void _setPostBody(String newPostBody) async {
    setState(() {
      _postBody = newPostBody;
    });
  }

  _makePost(context) async {
    setState(() {
      _isPosting = true;
    });
    String? postResponse;

    print(" make post");
    postResponse = await postController?.createPost(_postBody ?? "",
        imageUploader?.file?.name ?? "", imageUploader?.file?.bytes, context);

    setState(() {
      _isPosting = false;
    });

    print(" post response $postResponse");
    return postResponse ?? "FAIL";
  }

  _getMyProfileImage(PlatformFile? theFile) {
    if (theFile != null) {
      if (kDebugMode) {
        print("profile image is froom memory");
      }
      return MemoryImage(
        theFile.bytes ?? [] as Uint8List,
      );
    }
    if (kDebugMode) {
      print("profile image is default");
    }
    return const AssetImage('assets/blankProfileImage.png');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    _sendSuccess() async {
      await _alertSnackbar.showSuccessAlert("Post created:", context);
    }

    _sendError() async {
      await _alertSnackbar.showErrorAlert(
          "Post creation failed. Try again.", context);
    }

    return Scaffold(
      floatingActionButton: PostsPageMenu(
        updateMenu: () {},
      ),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        // Here we take the value from the LoginPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Logo(),
      ),
      body: FullPageLayout(
        child: Column(
          children: [
            AppImageUploader(
              height: 350,
              width: 350,
              text: "Change Main Post Photo",
              imageUploader: imageUploader!,
              uploadImage: (uploader) {
                imageUploader = uploader;
              },
            ),
            TextFormField(
              autofocus: true,
              onChanged: (e) {
                _setPostBody(e);
              },
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Post:',
              ),
            ),
            AnalyticsLoadingButton(
              analyticsEventName: 'create-post',
              analyticsEventData: {"body": _postBody, "author": ""},
              isDisabled: ((_postBody?.length ?? -1) <= 0),
              action: () async {
                var status = await _makePost(context);
                
                if (status == "SUCCESS") {
                  await _sendSuccess();
                } else if (status == "FAIL") {
                  await _sendError();
                }
              },
              text: "Post",
            )
          ],
        ),
      ),
    );
  }
}
