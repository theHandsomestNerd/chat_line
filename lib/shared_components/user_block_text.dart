import 'package:cookout/models/app_user.dart';
import 'package:cookout/sanity/sanity_image_builder.dart';
import 'package:flutter/material.dart';


class UserBlockText extends StatelessWidget {
  const UserBlockText({
    super.key,
    this.user,
    this.hideImage,
  });

  final AppUser? user;

  final bool? hideImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: Key((user?.userId ?? "") + (user?.displayName ?? "")),
      height: 30,
      width: 120,
      // width: 30,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          if (hideImage != true)
            Flexible(
              child: SizedBox(
                height: 30,
                width: 30,
                child: Image(
                  image: SanityImageBuilder.imageProviderFor(sanityImage:  user?.profileImage,width: 30,height: 30).image,
                ),
              ),
            ),
          Flexible(
            child: MaterialButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile',
                    arguments: {"id": user?.userId});
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
