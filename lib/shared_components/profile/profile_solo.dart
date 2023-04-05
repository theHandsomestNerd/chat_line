import 'package:cookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';

import '../../config/default_config.dart';
import '../../models/app_user.dart';
import '../../sanity/image_url_builder.dart';

class ProfileSolo extends StatelessWidget {
  const ProfileSolo({
    super.key,
    required this.profile,
  });

  final AppUser profile;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: super.key,
      onTap: () {
        Navigator.pushNamed(context, '/profile',
            arguments: {"id": profile.userId});
      },
      child: Stack(
        children: [
          profile.profileImage != null
              ? SizedBox(
                  height: 110,
                  width: 110,
                  child: CardWithBackground(
                    image: NetworkImage(MyImageBuilder()
                        .urlFor(profile.profileImage, 110, 110)!
                        .url()),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${profile.displayName}"),
                    ),
                  ),
                )
              : SizedBox(
                  height: 110,
                  width: 110,
                  child: CardWithBackground(
                    image: Image(
                            image: const AssetImage(
                                'assets/blankProfileImage.png'))
                        .image,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${profile.displayName}"),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
