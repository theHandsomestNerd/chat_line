import 'package:cookowt/models/controllers/auth_controller.dart';
import 'package:cookowt/sanity/sanity_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:go_router/go_router.dart';

import '../../models/controllers/auth_inherited.dart';

import '../../wrappers/expanding_fab.dart';

class ProfilePageMenu extends StatefulWidget {
  const ProfilePageMenu({
    Key? key,
    this.selected,
  }) : super(key: key);

  final bool? selected;

  @override
  State<ProfilePageMenu> createState() => _ProfilePageMenuState();
}

enum ProfileMenuOptions { PROFILELIST, TIMELINE, INBOX, BLOCKS, ALBUMS, POSTS }

class _ProfilePageMenuState extends State<ProfilePageMenu> {
  late SanityImage? profileImage;
  late AuthController authControlller;

  @override
  didChangeDependencies() async {
    var theAuthController = AuthInherited.of(context)?.authController;
    profileImage = theAuthController?.myAppUser?.profileImage;
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 158.0,
      children: [
        ActionButton(
          tooltip: "Settings",
          onPressed: () {
            GoRouter.of(context).go('/settings');

            // Navigator.popAndPushNamed(context, '/settings');
          },
          icon: const Icon(Icons.settings),
        ),
        // ActionButton(
        //   tooltip: "Posts",
        //   onPressed: () {
        //     widget.updateMenu(ProfileMenuOptions.POSTS.index);
        //   },
        //   icon: const Icon(Icons.post_add),
        // ),

        // ActionButton(
        //   tooltip: "Album",
        //   onPressed: () {
        //     widget.updateMenu(ProfileMenuOptions.ALBUMS.index);
        //   },
        //   icon: const Icon(Icons.photo_album),
        // ),
        // ActionButton(
        //   tooltip: "Inbox",
        //   onPressed: () {
        //     widget.updateMenu(ProfileMenuOptions.INBOX.index);
        //   },
        //   icon: const Icon(Icons.inbox),
        // ),
        // ActionButton(
        //   tooltip: "Timeline",
        //   onPressed: () {
        //     widget.updateMenu(ProfileMenuOptions.TIMELINE.index);
        //   },
        //   icon: const Icon(Icons.timeline),
        // ),
        ActionButton(
          tooltip: "Posts",
          onPressed: () {
            GoRouter.of(context).go('/postsPage');

            // Navigator.popAndPushNamed(context, '/postsPage');
          },
          icon: const Icon(Icons.timeline),
        ),
        ActionButton(
          tooltip: "My Profile",
          onPressed: () {
            GoRouter.of(context).go('/myProfile');

            // Navigator.pushNamed(context, '/myProfile');
          },
          icon: CircleAvatar(
            backgroundImage: SanityImageBuilder.imageProviderFor(
                    sanityImage: profileImage, showDefaultImage: true)
                .image,
          ),
        ),
        ActionButton(
          tooltip: "Home",
          onPressed: () {
            GoRouter.of(context).go('/home');

            // Navigator.popAndPushNamed(context, '/home');
          },
          icon: const Icon(Icons.home),
        ),
      ],
    );
  }
}
