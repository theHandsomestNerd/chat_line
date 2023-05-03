import 'dart:async';
import 'dart:io';

import 'package:kookout/wrappers/card_with_background.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'image_uploader_abstract.dart';

class ImageUploaderImpl extends ImageUploader {
  ImageUploaderImpl() {
    file = null;
    fileExtension = null;
    contentType = null;
    // pickedFile = null;
  }

  @override
  void clear() {
    file = null;
    notifyListeners();
  }

  // Future<void> _uploadImage() async {
  //   final pickedFile =
  //   await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       file = pickedFile;
  //     });
  //   }
  // }

  Widget _imageCard(
      BuildContext context, double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: kIsWeb ? 24.0 : 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                child: _image(screenWidth, screenHeight),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          _menu(context),
        ],
      ),
    );
  }

  Widget _uploaderCard(context, image) {
    return Center(
      child: CardWithBackground(
        // elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        image: image,
        child: SizedBox(
          width: kIsWeb ? 380.0 : 320.0,
          height: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: image == null
                      ? DottedBorder(
                          radius: const Radius.circular(12.0),
                          borderType: BorderType.RRect,
                          dashPattern: const [8, 4],
                          color:
                              Theme.of(context).highlightColor.withOpacity(0.4),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Theme.of(context).highlightColor,
                                  size: 80.0,
                                ),
                                const SizedBox(height: 24.0),
                                Text(
                                  'Upload an image to start',
                                  style: kIsWeb
                                      ? Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .highlightColor)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .highlightColor),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    _uploadImage();
                  },
                  child:
                      Text(image == null ? 'Upload' : "Change Profile Image"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage(context) async {
    if (file != null && file?.path != null) {
      final theCroppedFile = await ImageCropper().cropImage(
        sourcePath: file!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 350,
              height: 350,
            ),
            viewPort:
                const CroppieViewPort(width: 340, height: 340, type: 'rectangle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (theCroppedFile != null) {
        croppedFile = theCroppedFile;
        notifyListeners();
      }
    }
  }
  //
  // void _clear() {
  //   file = null;
  //   croppedFile = null;
  // }

  Future<void> _uploadImage() async {
    final pickedFile = await uploadImage();

    if (pickedFile != null) {
      file = pickedFile;
      notifyListeners();
    }
  }

  Widget _menu(context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {
            clear();
          },
          backgroundColor: Colors.redAccent,
          tooltip: 'Delete',
          child: const Icon(Icons.delete),
        ),
        if (croppedFile == null)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: FloatingActionButton(
              onPressed: () {
                _cropImage(context);
              },
              backgroundColor: const Color(0xFFBC764A),
              tooltip: 'Crop',
              child: const Icon(Icons.crop),
            ),
          )
      ],
    );
  }

  @override
  Widget body(context, double screenWidth, double screenHeight,
      ImageProvider? inputImage) {
    if (croppedFile != null || file != null) {
      return _imageCard(
        context,
        screenWidth,
        screenHeight,
      );
    } else {
      return _uploaderCard(context, inputImage);
    }
  }

  Widget _image(double screenWidth, double screenHeight) {
    if (croppedFile != null) {
      final path = croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else if (file != null) {
      final path = file!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Future<XFile?> uploadImage() async {
    final XFile? pickedImageFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 580,
        preferredCameraDevice: CameraDevice.rear);

    XFile? theFile;
    if (pickedImageFile != null) {
      theFile = XFile(pickedImageFile.path,
          bytes: await pickedImageFile.readAsBytes(),
          name: pickedImageFile.name,
          length: await pickedImageFile.length());

      file = theFile;
      notifyListeners();

      if (kDebugMode) {
        print(
            "File Picked ${theFile.name} extension:${theFile.mimeType} ${theFile.length()} bytes");
      }
      return theFile;
    } else {
      // User canceled the picker
    }
    return null;
  }
}
