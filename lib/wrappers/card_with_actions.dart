import 'package:cookout/models/app_user.dart';
import 'package:cookout/shared_components/user_block_text.dart';
import 'package:cookout/wrappers/author_and_text.dart';
import 'package:cookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../config/default_config.dart';

class CardWithActions extends StatelessWidget {
  final String? action1Text;
  final String? caption;
  final locationRow;

  final action1OnPressed;
  final ImageProvider image;

  final String? action2Text;

  final action2OnPressed;
  final infoCard;
  final DateTime? when;
  final AppUser? author;

  const CardWithActions(
      {super.key,
      this.when,
      this.caption,
      this.action1Text,
      this.action1OnPressed,
      this.action2Text,
      this.action2OnPressed,
      this.locationRow,
      this.infoCard,
      required this.image,
      this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: super.key,
      margin: const EdgeInsets.symmetric(
        vertical: 4.0,
        // horizontal: 24.0,
      ),
      child: Stack(
        children: [
          CardWithBackground(
            image: image,
            child: Column(
              mainAxisAlignment: caption != null
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (locationRow != null)
                  Padding(
                      padding: const EdgeInsets.all(8.0), child: locationRow!),
                if (infoCard != null)
                  Row(
                    children: [
                      Column(
                        children: [infoCard!],
                      )
                    ],
                  ),
                Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    if (action1Text != null)
                      Expanded(
                        child: MaterialButton(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(0.0)),
                          ),
                          color: Colors.black.withOpacity(.5),
                          onPressed: action1OnPressed,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 20, 20, 20.0),
                            child: Text(
                              action1Text!,
                              style:
                                  Theme.of(context).textTheme.bodyLarge?.merge(
                                        const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    // if (action2Text != null) const SizedBox(width: 8),
                    const SizedBox(width: 1),
                    if (action2Text != null)
                      Expanded(
                        child: MaterialButton(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(0.0)),
                          ),
                          color: Colors.black.withOpacity(.5),
                          onPressed: action2OnPressed,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              action2Text!,
                              style:
                                  Theme.of(context).textTheme.bodyLarge?.merge(
                                        const TextStyle(
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (caption != null)
            Column(
              children: [
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                      child: author != null
                          ? AuthorAndText(
                              author: author!,
                              when: when,
                              body: caption,
                            )
                          : Container(),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
