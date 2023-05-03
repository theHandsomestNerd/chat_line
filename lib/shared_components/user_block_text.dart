import 'package:cookowt/models/app_user.dart';
import 'package:cookowt/sanity/sanity_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../wrappers/card_with_background.dart';

class UserBlockText extends StatelessWidget {
  const UserBlockText({
    super.key,
    this.user,
    this.hideImage,
    this.hideText,
  });

  final AppUser? user;

  final bool? hideImage;
  final bool? hideText;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 67,
        maxWidth: 120,
      ),
      key: Key((user?.userId ?? "") + (user?.displayName ?? "")),
      // width: 30,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          if (hideImage != true)
            Flexible(
              child: InkWell(

              onTap: () {
                GoRouter.of(context).go('/profile/${user?.userId}');

                // Navigator.pushNamed(context, '/profile',
                //     arguments: {"id": user?.userId});
              },
                child: CardWithBackground(
                  height: 67,
                  width: 67,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(0)),
                    //set border radius more than 50% of height and width to make circle
                  ),
                  image: SanityImageBuilder.imageProviderFor(
                          sanityImage: user?.profileImage,
                          width: 67,
                          height: 67)
                      .image,
                  child: const SizedBox(height: 67, width: 67),
                ),
              ),
            ),
          if (hideText != true)
            Flexible(
              child: MaterialButton(
                onPressed: () {
                  GoRouter.of(context).go('/profile/${user?.userId}');

                  // Navigator.pushNamed(context, '/profile',
                  //     arguments: {"id": user?.userId});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(user?.displayName ?? ""),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
