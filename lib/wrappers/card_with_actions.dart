import 'package:kookout/models/app_user.dart';
import 'package:kookout/wrappers/author_and_text.dart';
import 'package:kookout/wrappers/card_with_background.dart';
import 'package:flutter/material.dart';

class CardWithActions extends StatelessWidget {
  final String? action1Text;
  final String? caption;
  final Widget? locationRow;

  final VoidCallback? action1OnPressed;
  final ImageProvider image;

  final String? action2Text;

  final VoidCallback? action2OnPressed;
  final Widget? infoCard;
  final DateTime? when;
  final AppUser? author;
  final int? width;
  final int? height;
  final IconData? action1Icon;
  final IconData? action2Icon;
  final bool? isAction1Active;
  final bool? isAction1Loading;

  const CardWithActions({
    super.key,
    this.when,
    this.isAction1Active,
    this.caption,
    this.isAction1Loading,
    this.action1Text,
    this.action1OnPressed,
    this.action1Icon,
    this.action2Icon,
    this.action2Text,
    this.action2OnPressed,
    this.locationRow,
    this.infoCard,
    this.height,
    this.width,
    required this.image,
    this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CardWithBackground(
          image: image,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 450, maxHeight: 450),
            child: Column(
              mainAxisAlignment: locationRow !=null?MainAxisAlignment.spaceBetween:MainAxisAlignment.end,
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
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,8.0),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        if (action1Text != null)
                          Expanded(
                            child: MaterialButton(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),

                              ),
                              color: Colors.black,
                              onPressed: action1OnPressed,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isAction1Loading == true?SizedBox(
                                      height: 12,
                                      width: 12,
                                      child: CircularProgressIndicator(
                                        color:
                                        isAction1Active == true ? Colors.blue : Colors.white,
                                      ),
                                    ):Icon(
                                      action1Icon,
                                      color: isAction1Active == true
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                    if(action1Icon != null)const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      action1Text!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.merge(
                                            TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: isAction1Active == true
                                                  ? Colors.blue
                                                  : Colors.white,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (action2Text != null) const SizedBox(width: 8),
                        const SizedBox(width: 1),
                        if (action2Text != null)
                          Expanded(
                            child: MaterialButton(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              ),
                              color: Colors.black,
                              onPressed: action2OnPressed,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      action2Icon,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      action2Text!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.merge(
                                            const TextStyle(
                                              color: Colors.white,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
    );
  }
}
