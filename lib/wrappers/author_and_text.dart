import 'package:cookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../sanity/sanity_image_builder.dart';
import '../shared_components/user_block_text.dart';
import 'package:timeago/timeago.dart' as timeago;

class AuthorAndText extends StatefulWidget {
  AuthorAndText({Key? key, required this.author, this.when, this.body, this.backgroundColor}) : super(key: key);
  final AppUser author;
  final String? body;
  final DateTime? when;
  final Color? backgroundColor;

  @override
  State<AuthorAndText> createState() => _AuthorAndTextState();
}

class _AuthorAndTextState extends State<AuthorAndText> {
  late ImageProvider authorImage;

  @override
  void initState() {

    authorImage = SanityImageBuilder.imageProviderFor(
        sanityImage: widget.author.profileImage)
        .image;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Card(
          margin: EdgeInsets.all(0),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
            //set border radius more than 50% of height and width to make circle
          ),
          color: widget.backgroundColor ?? Colors.white.withOpacity(.8),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              if (authorImage != null)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        68, 0,0,0),
                    child: Column(
                      children: [
                        if (widget.when != null)
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                  child: widget.author != null
                                      ? UserBlockText(
                                      hideImage: true,
                                      user: widget.author)
                                      : Text("")),
                              Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      Text(timeago
                                          .format(widget.when!)),
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
                                    12, 8.0, 8, 12),
                                child: Text(
                                  widget.body??"",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (authorImage != null)
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 67),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 2,
                  child: CardWithBackground(
                      height: 67,
                      width: 67,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0)),
                        //set border radius more than 50% of height and width to make circle
                      ),
                      image: authorImage,
                      child: const SizedBox(
                          height: 67, width: 67)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
