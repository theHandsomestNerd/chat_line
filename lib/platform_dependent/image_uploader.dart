import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';

import 'image_uploader_abstract.dart';

class ImageUploaderImpl extends ImageUploader {
  @override
  Future<XFile?> uploadImage() async {
    throw Exception("Stub implementation");
  }

  @override
  void clear() {
    // TODO: implement clear
  }

  @override
  Widget body(BuildContext context, double screenWidth, double screenHeight) {
    // TODO: implement body
    throw UnimplementedError();
  }
}
