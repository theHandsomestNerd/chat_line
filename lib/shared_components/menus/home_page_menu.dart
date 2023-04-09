import 'package:cookout/sanity/sanity_image_builder.dart';
import 'package:flutter/material.dart';

import '../../models/controllers/auth_inherited.dart';

import '../../wrappers/expanding_fab.dart';

class HomePageMenu extends StatefulWidget {
  const HomePageMenu({
    Key? key,
    required this.updateMenu,
    this.selected,
    
  }) : super(key: key);
  final updateMenu;
  final selected;
  

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
  var profileImage = null;

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    profileImage =
        AuthInherited.of(context)?.authController?.myAppUser?.profileImage;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
     
      distance: 158.0,
      children: [
        ActionButton(
          tooltip: "Settings",
          onPressed: () {
            Navigator.popAndPushNamed(context, '/settings');
          },
          icon: const Icon(Icons.settings),
        ),
        ActionButton(
          tooltip: "Album",
          onPressed: () {
            widget.updateMenu(ProfileMenuOptions.ALBUMS.index);
          },
          icon: const Icon(Icons.photo_album),
        ),
        ActionButton(
          tooltip: "Inbox",
          onPressed: () {
            widget.updateMenu(ProfileMenuOptions.LIKES_AND_FOLLOWS.index);
          },
          icon: const Icon(Icons.inbox),
        ),
        ActionButton(
          tooltip: "Timeline",
          onPressed: () {
            widget.updateMenu(ProfileMenuOptions.TIMELINE.index);
          },
          icon: const Icon(Icons.timeline),
        ),
        ActionButton(
          tooltip: "Profiles",
          onPressed: () {
            Navigator.popAndPushNamed(context, '/profilesPage');
          },
          icon: const Icon(Icons.people),
        ),
        ActionButton(
          tooltip: "Posts",
          onPressed: () {
            Navigator.popAndPushNamed(context, '/postsPage');
          },
          icon: const Icon(Icons.post_add),
        ),
        ActionButton(
          tooltip: "My Profile",
          onPressed: () {
            Navigator.pushNamed(context, '/myProfile');
          },
          icon: CircleAvatar(
                  backgroundImage: SanityImageBuilder.imageProviderFor(sanityImage: profileImage,showDefaultImage: true).image,
                ),
        ),
      ],
    );
  }
}
