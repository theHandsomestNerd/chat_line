import 'package:cookout/models/app_user.dart';
import 'package:cookout/shared_components/user_block_text.dart';
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
  final String? authorImageUrl;

  final String? action2Text;

  final action2OnPressed;
  final infoCard;
  final DateTime? when;
  final authorId;
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
      this.authorImageUrl,
      this.authorId,
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
                      padding: const EdgeInsets.all(8.0),
                      child: locationRow!),
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
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              action1Text!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.merge(
                                const TextStyle(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.merge(
                                const TextStyle(
                                  color: Colors.white,
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
                    Expanded(
                      child: Stack(
                        children: [
                          Card(
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                              ),
                              //set border radius more than 50% of height and width to make circle
                            ),
                            color: Colors.white.withOpacity(.8),
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [
                                if (authorImageUrl != null)
                                  Flexible(
                                    child: SizedBox(
                                      // height: 80,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            78.0, 8.0, 8.0, 8.0),
                                        child: Column(
                                          children: [
                                            if (when != null)
                                              Flex(
                                                direction: Axis.horizontal,
                                                children: [
                                                  Expanded(
                                                      child: author != null
                                                          ? UserBlockText(
                                                          hideImage: true,
                                                          user: author)
                                                          : Text("")),
                                                  Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                        children: [
                                                          Text(timeago
                                                              .format(when!)),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            Flex(
                                              direction: Axis.horizontal,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(
                                                        8, 0, 0, 0),
                                                    child: Text(
                                                      caption!,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (authorImageUrl != null &&
                              (authorImageUrl?.length ?? -1) > 0)
                            Flex(
                              direction: Axis.horizontal,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 70,
                                    width: 70,
                                    child: CardWithBackground(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0)),
                                          //set border radius more than 50% of height and width to make circle
                                        ),
                                        image: NetworkImage(authorImageUrl!),
                                        child: const SizedBox(
                                            height: 70, width: 70)),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
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
