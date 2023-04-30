import 'package:kookout/models/controllers/analytics_controller.dart';
import 'package:kookout/models/controllers/auth_controller.dart';
import 'package:kookout/wrappers/analytics_loading_button.dart';
import 'package:kookout/wrappers/text_field_wrapped.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_user.dart';
import '../../models/controllers/auth_inherited.dart';
import '../../models/controllers/chat_controller.dart';
import '../../models/extended_profile.dart';
import '../../models/submodels/height.dart';
import '../../platform_dependent/image_uploader.dart'
    if (dart.library.io) '../../platform_dependent/image_uploader_io.dart'
    if (dart.library.html) '../../platform_dependent/image_uploader_html.dart';
import '../../platform_dependent/image_uploader_abstract.dart';
import '../../sanity/sanity_image_builder.dart';
import '../../shared_components/app_image_uploader.dart';
import '../../shared_components/height_input.dart';
import '../../wrappers/alerts_snackbar.dart';

class EditProfileTab extends StatefulWidget {
  const EditProfileTab({
    Key? key,
    this.analyticsController,
  }) : super(key: key);

  final AnalyticsController? analyticsController;

  @override
  State<EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<EditProfileTab> {
  ExtendedProfile? extProfile;
  AppUser? _myAppUser;
  ChatController? chatController;
  AuthController? authController;

  String _loginUsername = "";
  String _displayName = "";
  late ImageUploader imageUploader;

  String _shortBio = "";
  String _longBio = "";
  String _iAm = "";
  String _imInto = "";
  String _imOpenTo = "";
  String _whatIDo = "";
  String _whatImLookingFor = "";
  String _whatInterestsMe = "";
  String _whereILive = "";
  String _sexPreferences = "";
  bool isUpdating = false;
  late SanityImage? profileImage;

  int _age = 0;
  int _weight = 0;
  final AlertSnackbar _alertSnackbar = AlertSnackbar();

  Uint8List? theFileBytes;

  @override
  initState() {
    super.initState();
    var theUploader = ImageUploaderImpl();
    imageUploader = theUploader;

    theUploader.addListener(() async {
      if (kDebugMode) {
        print("image uploader change");
      }
      if(theUploader.croppedFile != null){
        if (kDebugMode) {
          print("there iz a cropped");
        }
        theFileBytes = await theUploader.croppedFile?.readAsBytes();
      } else {
        if (kDebugMode) {
          print("there iz a file");
        }
        theFileBytes = await theUploader.file?.readAsBytes();
      }
      setState(() {

      });
    });
  }

  @override
  didChangeDependencies() async {
    var theAuthController = AuthInherited.of(context)?.authController;
    var theChatController = AuthInherited.of(context)?.chatController;
    var theUser = AuthInherited.of(context)?.authController?.myAppUser;

    chatController = theChatController;
    authController = theAuthController;
    _myAppUser = theUser;
    profileImage = theUser?.profileImage;

    if (theUser?.userId != null) {
      theChatController?.updateExtProfile((theUser?.userId)!);
      extProfile = await theChatController?.profileClient
          .getExtendedProfile((theUser?.userId)!);
    }
    super.didChangeDependencies();
  }

  void _setUsername(String newUsername) async {
    await widget.analyticsController
        ?.logScreenView('set-username-field-edit-profile');
    setState(() {
      _loginUsername = newUsername;
    });
  }

  void _setDisplayName(String newDisplayName) {
    setState(() {
      _displayName = newDisplayName;
    });
  }

  void _setShortBio(String newShortBio) {
    setState(() {
      _shortBio = newShortBio;
    });
  }

  void _setLongBio(String newLongBio) {
    setState(() {
      _longBio = newLongBio;
    });
  }

  void _setIAm(String newIAm) {
    setState(() {
      _iAm = newIAm;
    });
  }

  void _setImInto(String newImInto) {
    setState(() {
      _imInto = newImInto;
    });
  }

  void _setImOpenTo(String newImOpenTo) {
    setState(() {
      _imOpenTo = newImOpenTo;
    });
  }

  void _setWhatIDo(String newWhatIDo) {
    setState(() {
      _whatIDo = newWhatIDo;
    });
  }

  void _setWhatImLookingFor(String newWhatImLookingFor) {
    setState(() {
      _whatImLookingFor = newWhatImLookingFor;
    });
  }

  void _setWhatInterestsMe(String newWhatInterestsMe) {
    setState(() {
      _whatInterestsMe = newWhatInterestsMe;
    });
  }

  void _setWhereILive(String newWhereILive) {
    setState(() {
      _whereILive = newWhereILive;
    });
  }

  void _setSexPreferences(String newSexPreference) {
    setState(() {
      _sexPreferences = newSexPreference;
    });
  }

  void _setWeight(int newWeight) {
    setState(() {
      _weight = newWeight;
    });
  }

  void _setAge(int newAge) {
    setState(() {
      _age = newAge;
    });
  }

  Future<void> _updateProfile(context) async {
    setState(() {
      isUpdating = true;
    });
    try {
      // var theFileBytes = await imageUploader.file?.readAsBytes();
      //
      // if(imageUploader.croppedFile != null){
      //   theFileBytes = await imageUploader.croppedFile?.readAsBytes();
      // }


      var authUser = await authController?.updateUser(
          _loginUsername,
          _displayName,
          imageUploader.file?.name ?? "",
          theFileBytes,
          context);
      if (kDebugMode) {
        print("updated fields in authuser result: $authUser");

        print("id to create ${authUser?.uid}");
      }

      ExtendedProfile newProfile = ExtendedProfile(
        shortBio: _shortBio != "" ? _shortBio : null,
        height: _height,
        longBio: _longBio != "" ? _longBio : null,
        age: _age != 0 ? _age : null,
        weight: _weight != 0 ? _weight : null,
        iAm: _iAm != "" ? _iAm : null,
        imInto: _imInto != "" ? _imInto : null,
        imOpenTo: _imOpenTo != "" ? _imOpenTo : null,
        whatIDo: _whatIDo != "" ? _whatIDo : null,
        whatImLookingFor: _whatImLookingFor != "" ? _whatImLookingFor : null,
        whatInterestsMe: _whatInterestsMe != "" ? _whatInterestsMe : null,
        whereILive: _whereILive != "" ? _whereILive : null,
        sexPreferences: _sexPreferences != "" ? _sexPreferences : null,
      );

      if (kDebugMode) {
        print("parsed request from user form: $newProfile");
      }

      var aUser = await chatController?.profileClient
          .updateExtProfileChatUser(authUser?.uid ?? "", context, newProfile);
      if (kDebugMode) {
        print("updated extended profile $aUser");
      }

      extProfile = aUser;
      setState(() {
        isUpdating = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _alertSnackbar.showSuccessAlert(
        "Profile Updated. Now get out there in crowd.", context);
    // Navigator.pushNamed(
    //   context,
    //   '/home',
    // );
    GoRouter.of(context).go('/home');

  }

  Height? _height;

  _updateHeight(int newFeet, int newInches) {
    setState(() {
      _height = Height.withValues(newFeet, newInches);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ObjectKey(imageUploader),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Edit Profile',
          ),
          Flexible(
            child: ListView(
              children: [
                ListTile(
                  title: AppImageUploader(
                    height: 350,
                    width: 350,
                    image: SanityImageBuilder.imageProviderFor(
                        sanityImage: profileImage, showDefaultImage: true)
                        .image,
                    text: "Change Profile Photo",
                    imageUploader: imageUploader,
                    uploadImage: (theImageUploader) {
                      imageUploader = theImageUploader;
                      setState(() {});
                    },
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(_myAppUser?.email ?? "-mail"),
                    initialValue: _myAppUser?.email,
                    enabled: false,
                    setField: (e) {
                      _setUsername(e);
                    },
                    labelText: 'Username',
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(
                        "${_myAppUser?.displayName ?? ""}-display-name"),
                    initialValue: _myAppUser?.displayName,
                    setField: (e) {
                      _setDisplayName(e);
                    },
                    labelText: 'Display Name',
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFieldWrapped(
                          key: ObjectKey(
                              "${extProfile?.age.toString() ?? ""}-age"),
                          initialValue: extProfile?.age.toString() ?? "",
                          setField: (e) {
                            _setAge(int.parse(e));
                          },
                          labelText: "Age",
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        flex: 2,
                        child: TextFieldWrapped(
                          key: ObjectKey(
                              "${extProfile?.weight.toString() ?? ""}-weight"),
                          initialValue: extProfile?.weight.toString(),
                          setField: (e) {
                            _setWeight(int.parse(e));
                          },
                          labelText: 'Weight',
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Flex(direction: Axis.horizontal, children: [
                    Flexible(
                      child: HeightInput(
                        initialValue: extProfile?.height,
                        updateHeight: _updateHeight,
                      ),
                    ),
                  ]),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey("${extProfile?.shortBio}-short-bio"),
                    initialValue: extProfile?.shortBio,
                    setField: (e) {
                      _setShortBio(e);
                    },
                    labelText: "Short Bio",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey("${extProfile?.longBio}-long-bio"),
                    initialValue: extProfile?.longBio ?? "",
                    setField: (e) {
                      _setLongBio(e);
                    },
                    labelText: "Long Bio",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey("${extProfile?.iAm}-i-am"),
                    initialValue: extProfile?.iAm ?? "",
                    setField: (e) {
                      _setIAm(e);
                    },
                    labelText: "I am",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey("${extProfile?.imInto}-im-into"),
                    initialValue: extProfile?.imInto ?? "",
                    setField: (e) {
                      _setImInto(e);
                    },
                    labelText: "I'm Into",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey("${extProfile?.imOpenTo}-im-open-to"),
                    initialValue: extProfile?.imOpenTo ?? "",
                    setField: (e) {
                      _setImOpenTo(e);
                    },
                    labelText: "I'm open to",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey("${extProfile?.whatIDo}-what-i-do"),
                    initialValue: extProfile?.whatIDo ?? "",
                    setField: (e) {
                      _setWhatIDo(e);
                    },
                    labelText: "What I Do?",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(
                        "${extProfile?.whatImLookingFor}-what-im-looking-for"),
                    // controller: _longBioController,
                    initialValue: extProfile?.whatImLookingFor ?? "",
                    setField: (e) {
                      _setWhatImLookingFor(e);
                    },
                    labelText: "What Im Looking for",

                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(
                        "${extProfile?.whatInterestsMe}-what-interests-me"),
                    // controller: _longBioController,
                    initialValue: extProfile?.whatInterestsMe ?? "",
                    setField: (e) {
                      _setWhatInterestsMe(e);
                    },
                    labelText: "What interests Me",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey("${extProfile?.whereILive}-where-i-live"),
                    // controller: _longBioController,
                    initialValue: extProfile?.whereILive ?? "",
                    setField: (e) {
                      _setWhereILive(e);
                    },
                    labelText: "Where I Live",

                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(
                        "${extProfile?.sexPreferences}-sex-preferences"),
                    initialValue: extProfile?.sexPreferences ?? "",
                    setField: (e) {
                      _setSexPreferences(e);
                    },
                    labelText: "Sex Preferences",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: AnalyticsLoadingButton(
                    analyticsEventData: {
                      'username': _myAppUser?.email,
                      'sex_preferences': ((extProfile?.sexPreferences?.length ?? 0) > 0).toString(),
                      'height': (extProfile?.height != null).toString(),
                      'weight': (extProfile?.weight != null).toString(),
                      'age': (extProfile?.age != null).toString(),
                      'where_i_live': ((extProfile?.whereILive?.length ?? 0) > 0).toString(),
                      'what_interests_me': ((extProfile?.whatInterestsMe?.length ?? 0) > 0).toString(),
                      'what_im_looking_for': ((extProfile?.whatImLookingFor?.length ?? 0) > 0).toString(),
                      'what_i_do': ((extProfile?.whatIDo?.length ?? 0) > 0).toString(),
                      'im_open_to': ((extProfile?.imOpenTo?.length ?? 0) > 0).toString(),
                      'i_am': ((extProfile?.iAm?.length ?? 0) > 0).toString(),
                      'short_bio': ((extProfile?.shortBio?.length ?? 0) > 0).toString(),
                      'long_bio': ((extProfile?.longBio?.length ?? 0) > 0).toString(),
                    },
                    analyticsEventName: 'settings-save-profile',
                    isDisabled: isUpdating,
                    action: (innerContext) async {
                      await _updateProfile(context);
                    },
                    text: "Save Profile",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
