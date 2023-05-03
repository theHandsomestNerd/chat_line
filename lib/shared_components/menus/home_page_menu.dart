import 'package:cookowt/sanity/sanity_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:go_router/go_router.dart';

import '../../models/controllers/auth_inherited.dart';

import '../../wrappers/expanding_fab.dart';

class HomePageMenu extends StatefulWidget {
  const HomePageMenu({
    Key? key,
    required this.updateMenu,
    this.selected,
    
  }) : super(key: key);
  final Function updateMenu;
  final bool? selected;
  

  @override
  State<HomePageMenu> createState() => _HomePageMenuState();
}

enum ProfileMenuOptions {
  TIMELINE,
  LIKES_AND_FOLLOWS,
  BLOCKS,
  ALBUMS,
}

class _HomePageMenuState extends State<HomePageMenu> {
  SanityImage? profileImage;

  @override
  didChangeDependencies() async {
    profileImage =
        AuthInherited.of(context)?.authController?.myAppUser?.profileImage;
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
        //   tooltip: "Album",
        //   onPressed: () {
        //     widget.updateMenu(ProfileMenuOptions.ALBUMS.index);
        //   },
        //   icon: const Icon(Icons.photo_album),
        // ),
        // ActionButton(
        //   tooltip: "Inbox",
        //   onPressed: () {
        //     widget.updateMenu(ProfileMenuOptions.LIKES_AND_FOLLOWS.index);
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
        // ActionButton(
        //   tooltip: "Profiles",
        //   onPressed: () {
        //     GoRouter.of(context).go('/profilesPage');
        //
        //     // Navigator.popAndPushNamed(context, '/profilesPage');
        //   },
        //   icon: const Icon(Icons.people),
        // ),
        ActionButton(
          tooltip: "Profiles",
          onPressed: () {
            GoRouter.of(context).go('/profilesPage');

            // Navigator.popAndPushNamed(context, '/profilesPage');
          },
          icon: const Icon(Icons.people),
        ),
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
                  backgroundImage: SanityImageBuilder.imageProviderFor(sanityImage: profileImage,showDefaultImage: true).image,
                ),
        ),
      ],
    );
  }
}
