import 'package:cookout/models/app_user.dart';
import 'package:flutter/material.dart';

import '../config/default_config.dart';
import '../sanity/image_url_builder.dart';

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
                child: user?.profileImage != null
                    ? Image.network(
                        MyImageBuilder()
                                .urlFor(user!.profileImage, 50, 50)!
                                .url() ??
                            "",
                        height: 30,
                        width: 30,
                      )
                    : Image.asset(
                        height: 30, width: 30, 'assets/blankProfileImage.png'),
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
