import 'package:kookout/models/controllers/analytics_controller.dart';
import 'package:kookout/sanity/sanity_image_builder.dart';
import 'package:kookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  AnalyticsController? analyticsController;
  String? myUserId;
  @override
  didChangeDependencies() async {
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    if(analyticsController == null && theAnalyticsController != null) {
      analyticsController = theAnalyticsController;
    }

    myUserId =
        AuthInherited.of(context)?.authController?.myAppUser?.userId ?? "";
    setState(() {});
    super.didChangeDependencies();
  }

  _gotoProfile() async {
    analyticsController?.sendAnalyticsEvent('profile-clicked', {"clicker": myUserId, "clicked": widget.profile.userId});

    GoRouter.of(context).go('/profile/${widget.profile.userId}');

    // Navigator.pushNamed(context, '/profile',
    //     arguments: {"id": widget.profile.userId});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await _gotoProfile();
      },
      child: Stack(
        children: [
          widget.profile.profileImage != null
              ? ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 125, minWidth: 125),
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
                  height: 125,
                  width: 125,
                  child: CardWithBackground(
                    height: 125,
                    width: 125,
                    image: const Image(
                            image: AssetImage(
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
