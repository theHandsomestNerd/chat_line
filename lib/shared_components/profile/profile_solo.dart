import 'package:cookout/models/controllers/analytics_controller.dart';
import 'package:cookout/sanity/sanity_image_builder.dart';
import 'package:cookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';

import '../../config/default_config.dart';
import '../../models/app_user.dart';
import '../../models/controllers/auth_inherited.dart';


class ProfileSolo extends StatefulWidget {
  const ProfileSolo({
    super.key,
    required this.profile,
  });

  final AppUser profile;

  @override
  State<ProfileSolo> createState() => _ProfileSoloState();
}

class _ProfileSoloState extends State<ProfileSolo> {
  AnalyticsController? analyticsController=null;
  String? myUserId;
  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var theAuthController = AuthInherited.of(context)?.authController;
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    if(analyticsController == null && theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
    }

    myUserId =
        AuthInherited.of(context)?.authController?.myAppUser?.userId ?? "";
    setState(() {});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await analyticsController?.sendAnalyticsEvent('profile-clicked', {"clicker": myUserId, "clicked": widget.profile.userId});
        Navigator.pushNamed(context, '/profile',
            arguments: {"id": widget.profile.userId});
      },
      child: Stack(
        children: [
          widget.profile.profileImage != null
              ? ConstrainedBox(
            constraints: BoxConstraints(minHeight: 120, minWidth: 120),
                child: Hero(
                  tag: widget.profile.userId ?? "",
                  child: CardWithBackground(
                    image: SanityImageBuilder.imageProviderFor(sanityImage: widget.profile.profileImage,width:110,height:110).image,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text("${widget.profile.displayName}"),
                    ),
                  ),
                )
              )
              : SizedBox(
                  height: 100,
                  width: 100,
                  child: CardWithBackground(
                    image: Image(
                            image: const AssetImage(
                                'assets/blankProfileImage.png'))
                        .image,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${widget.profile.displayName}"),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
