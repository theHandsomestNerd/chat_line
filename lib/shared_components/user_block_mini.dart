import 'package:kookout/models/app_user.dart';
import 'package:kookout/sanity/sanity_image_builder.dart';
import 'package:kookout/wrappers/card_with_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class UserBlockMini extends StatelessWidget {
  const UserBlockMini({
    super.key,
    this.user,


  });

  final AppUser? user;



  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: Key((user?.userId ?? "") +
          (user?.displayName ?? "") +
          (user?.profileImage?.toString() ?? "")),
      constraints: const BoxConstraints(),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 48),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                            flex: 4,
                    child: MaterialButton(
                      onPressed: () {
                        GoRouter.of(context).go('/myProfile');

                        // Navigator.pushNamed(context, '/myProfile');
                      },
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            flex: 1,
                            child: CardWithBackground(image: SanityImageBuilder.imageProviderFor(sanityImage: user?.profileImage,width: 80,height: 80).image, child: const SizedBox(width:80,height: 80),),
                          ),
                          Flexible(
                            flex: 3,
                            child: Flex(
                              direction: Axis.vertical,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(child: Text(user?.displayName ?? "", style: Theme.of(context).textTheme.titleSmall,)),
                                // Flexible(child: Text(user?.email ?? ""))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            GoRouter.of(context).go('/settings');

                            // Navigator.popAndPushNamed(context, '/settings');
                          },
                          icon: const Icon(
                            Icons.settings,
                            size: 24.0,
                            semanticLabel: 'Edit Profile',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      icon: const Icon(
                        Icons.logout,
                        size: 24.0,
                        semanticLabel: 'Logout',
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
