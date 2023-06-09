import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../wrappers/expanding_fab.dart';
enum AppMenuOptions {
  BIO,
  COMMENTS,
  FOLLOWS,
  LIKES,
  ALBUMS
}
class AppMenu extends StatefulWidget {
  const AppMenu({Key? key, required this.updateMenu}) : super(key: key);
final Function updateMenu;
  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> {
  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 132.0,
      children: [
         ActionButton(
                onPressed: () {
                 widget.updateMenu(AppMenuOptions.BIO.index);
                },
                icon: const Icon(Icons.person),
              ),
        ActionButton(
          onPressed: () {
            widget.updateMenu(AppMenuOptions.COMMENTS.index);
          },
          icon: const Icon(Icons.comment),
        ),
      ActionButton(
          onPressed: () {
            widget.updateMenu(AppMenuOptions.LIKES.index);
          },
          icon: const Icon(Icons.thumb_up),
        ),
      ActionButton(
          onPressed: () {
            widget.updateMenu(AppMenuOptions.FOLLOWS.index);
          },
          icon: const Icon(Icons.favorite),
        ),
      ActionButton(

          onPressed: () {
            widget.updateMenu(AppMenuOptions.ALBUMS.index);
          },
          icon: const Icon(Icons.photo_album),
        ),
        ActionButton(
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
