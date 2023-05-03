import 'package:cookowt/sanity/sanity_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';

class SanityImageBuilder {
  final int? height;
  final int? width;
  final SanityImage? _sanityImage;
  final bool? showDefaultImage;
  final builder = ImageUrlBuilder(sanityClient());
  String? url;

  late ImageProvider image =
      const Image(image: AssetImage('assets/blankProfileImage.png')).image;

  SanityImageBuilder.imageProviderFor(
      {required SanityImage? sanityImage,
      this.height,
      this.width,
      this.showDefaultImage})
      : _sanityImage = sanityImage {
    if (_sanityImage != null) {
      var theBuilder = builder.image(_sanityImage!);

      if (height != null) {
        theBuilder.height(height!);
      }
      if (width != null) {
        theBuilder.width(width!);
      }

      var theUrl = theBuilder.url();

      url = theUrl;
      if (theUrl != "") {
        image = Image(image: NetworkImage(theUrl)).image;
      }
    }
  }
}
