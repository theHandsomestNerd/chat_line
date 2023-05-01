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

  String _facebook = "";
  String _twitter = "";
  String _instagram = "";
  String _tiktok = "";
  String _govtIssuedFirstName = "";
  String _govtIssuedMiddleName = "";
  String _govtIssuedLastName = "";
  String _homeNumber = "";
  String _workNumber = "";
  String _cellNumber = "";
  String _ethnicity = "";
  String _occupation = "";
  String _address1 = "";
  String _address2 = "";
  String _city = "";
  String _state = "";
  String _zip = "";
  String _lineName = "";
  String _lineNumber = "";
  String _dopName = "";
  String _entireLinesName = "";
  String _otherChapterAffiliation = "";
  String _crossingDate = "";
  DateTime? _dob = null;
  List<String> _children = [];

  bool isUpdating = false;
  late SanityImage? profileImage;

  int _age = 0;
  int _weight = 0;
  final AlertSnackbar _alertSnackbar = AlertSnackbar();

  Uint8List? theFileBytes;

  @override
  initState() {
    super.initState();
    widget.analyticsController
        ?.logScreenView('set-username-field-edit-profile');
    var theUploader = ImageUploaderImpl();
    imageUploader = theUploader;

    theUploader.addListener(() async {
      if (kDebugMode) {
        print("image uploader change");
      }
      if (theUploader.croppedFile != null) {
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
      setState(() {});
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

    setState(() {
      _loginUsername = newUsername;
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
      var authUser = await authController?.updateUser(_loginUsername,
          _displayName, imageUploader.file?.name ?? "", theFileBytes, context);
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
        lineName: _lineName != 0 ? _lineName : null,
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

  getListTile(String? value, String label, Function setValue) {
    return ListTile(
      title: TextFieldWrapped(
        key: ObjectKey("$value-${label.replaceAll(' ', '-').toLowerCase()}"),
        initialValue: value ?? "",
        setField: (e) {
          setValue(e);
        },
        labelText: label,
        minLines: 2,
        maxLines: 4,
      ),
    );
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
                      _displayName = e;
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
                getListTile(extProfile?.dob.toString(), "Date of Birth", (e) {
                  setState(() {
                    _dob = e;
                  });
                }),
                getListTile(extProfile?.govtIssuedFirstName, "First Name", (e) {
                  setState(() {
                    _govtIssuedFirstName = e;
                  });
                }),
                getListTile(extProfile?.govtIssuedMiddleName, "Middle Name",
                    (e) {
                  setState(() {
                    _govtIssuedMiddleName = e;
                  });
                }),
                getListTile(extProfile?.govtIssuedLastName, "Last Name", (e) {
                  setState(() {
                    _govtIssuedLastName = e;
                  });
                }),
                getListTile(extProfile?.shortBio, "Short Bio", (e) {
                  setState(() {
                    _shortBio = e;
                  });
                }),
                getListTile(extProfile?.longBio, "Long Bio", (e) {
                  setState(() {
                    _longBio = e;
                  });
                }),
                getListTile(extProfile?.address1, "Address 1", (e) {
                  setState(() {
                    _address1 = e;
                  });
                }),
                getListTile(extProfile?.address2, "Address 2", (e) {
                  setState(() {
                    _address2 = e;
                  });
                }),
                getListTile(extProfile?.city, "City", (e) {
                  setState(() {
                    _city = e;
                  });
                }),
                getListTile(extProfile?.state, "State", (e) {
                  setState(() {
                    _state = e;
                  });
                }),
                getListTile(extProfile?.otherChapterAffiliation, "Other Chapter Affiliation", (e) {
                  setState(() {
                    _otherChapterAffiliation = e;
                  });
                }),
                getListTile(extProfile?.lineName, "Line Name", (e) {
                  setState(() {
                    _lineName = e;
                  });
                }),
                getListTile(extProfile?.lineNumber, "Line Number", (e) {
                  setState(() {
                    _lineNumber = e;
                  });
                }),
                getListTile(extProfile?.entireLinesName, "Entire Lines Name", (e) {
                  setState(() {
                    _entireLinesName = e;
                  });
                }),
                getListTile(extProfile?.dopName, "Dean's Name", (e) {
                  setState(() {
                    _dopName = e;
                  });
                }),
                getListTile(extProfile?.crossingDate.toString(), "Crossing Date", (e) {
                  setState(() {
                    _crossingDate = e;
                  });
                }),

                ListTile(
                  title: AnalyticsLoadingButton(
                    analyticsEventData: {
                      'username': _myAppUser?.email,
                      'height': (extProfile?.height != null).toString(),
                      'weight': (extProfile?.weight != null).toString(),
                      'age': (extProfile?.age != null).toString(),
                      'short_bio':
                          ((extProfile?.shortBio?.length ?? 0) > 0).toString(),
                      'long_bio':
                          ((extProfile?.longBio?.length ?? 0) > 0).toString(),
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
