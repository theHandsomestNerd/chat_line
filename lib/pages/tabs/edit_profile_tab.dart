import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:go_router/go_router.dart';
import 'package:cookowt/models/controllers/analytics_controller.dart';
import 'package:cookowt/models/controllers/auth_controller.dart';
import 'package:cookowt/wrappers/analytics_loading_button.dart';
import 'package:cookowt/wrappers/date_input_wrapped.dart';
import 'package:cookowt/wrappers/text_field_wrapped.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../models/app_user.dart';
import '../../models/clients/api_client.dart';
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
import '../../wrappers/dropdown_input_wrapped.dart';

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

  ApiClient? apiClient;
  AuthController? authController;

  String? _loginUsername;
  String? _displayName;
  late ImageUploader imageUploader;

  String? _shortBio;
  String? _longBio;

  String? _facebook;
  String? _twitter;
  String? _instagram;
  String? _tiktok;
  String? _govtIssuedFirstName;
  String? _govtIssuedMiddleName;
  String? _govtIssuedLastName;
  String? _homePhone;
  String? _workPhone;
  String? _cellPhone;
  String? _ethnicity;
  String? _occupation;
  String? _address1;
  String? _address2;
  String? _city;
  String? _state;
  String? _zip;
  String? _lineName;
  String? _lineNumber;
  String? _dopName;
  String? _entireLinesName;
  String? _otherChapterAffiliation;
  DateTime? _crossingDate;
  DateTime? _dob;
  List<String>? _children;

  bool isUpdating = false;
  SanityImage? profileImage;

  String? _age;
  Height? _height = null;
  String? _weight;
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
    super.didChangeDependencies();

    var theAuthController = AuthInherited.of(context)?.authController;
    var theChatController = AuthInherited.of(context)?.chatController;
    var theUser = AuthInherited.of(context)?.authController?.myAppUser;
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;

    if (theAuthController != null && authController == null) {
      authController = theAuthController;
    }
    if (theClient != null && apiClient == null) {
      apiClient = theClient;
    }

    if (theUser != null && _myAppUser == null) {
      _myAppUser = theUser;
      _displayName = theUser.displayName;
      _loginUsername = theUser.email;
      profileImage = theUser.profileImage;
      setState(() {});
    }

    if (theUser?.userId != null && extProfile == null) {
      var theProfile =
          await theChatController?.updateExtProfile((theUser?.userId)!);
      setStateFromExtProfile(theProfile);
    }
  }

  setStateFromExtProfile(ExtendedProfile? aUser) {
    setState(() {
      if (aUser != null) {
        extProfile = aUser;
        _shortBio = aUser.shortBio;
        _longBio = aUser.longBio;
        _age = aUser.age.toString();
        _height = aUser.height;
        _weight = aUser.weight.toString();
        _facebook = aUser.facebook;
        _twitter = aUser.twitter;
        _instagram = aUser.instagram;
        _tiktok = aUser.tiktok;
        _govtIssuedFirstName = aUser.govtIssuedFirstName;
        _govtIssuedMiddleName = aUser.govtIssuedMiddleName;
        _govtIssuedLastName = aUser.govtIssuedLastName;
        print("home ${aUser.homePhone?.replaceFirst("+1", "")}");
        print("cell ${aUser.cellPhone?.replaceFirst("+1", "")}");
        print("work ${aUser.workPhone?.replaceFirst("+1", "")}");
        if (aUser.workPhone != null) {
          _workPhone = aUser.workPhone?.replaceFirst("+1", "");
        }
        if (aUser.cellPhone != null) {
          _cellPhone = aUser.cellPhone?.replaceFirst("+1", "");
        }
        if (aUser.homePhone != null) {
          _homePhone = aUser.homePhone?.replaceFirst("+1", "");
        }
        _ethnicity = aUser.ethnicity;
        _occupation = aUser.occupation;
        _address1 = aUser.address1;
        _address2 = aUser.address2;
        _city = aUser.city;
        _state = aUser.state;
        _zip = aUser.zip;
        _lineName = aUser.lineName;
        _lineNumber =
            aUser.lineNumber != null ? aUser.lineNumber.toString() : null;
        _dopName = aUser.dopName;
        _entireLinesName = aUser.entireLinesName;
        _otherChapterAffiliation = aUser.otherChapterAffiliation;
        _crossingDate = aUser.crossingDate;
        _dob = aUser.dob;
      }
      isUpdating = false;
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

      processLineNumber(String? number) {
        print("Linenumber is $number");

        if (number != null) {
          String theNumber = number;
          return int.parse(theNumber);
        }

        return null;
      }

      ExtendedProfile newProfile = ExtendedProfile(
        shortBio: _shortBio,
        height: _height,
        longBio: _longBio,
        age: _age != null ? int.parse(_age!) : null,
        weight: _weight != null ? int.parse(_weight!) : null,
        lineName: _lineName,
        entireLinesName: _entireLinesName,
        dopName: _dopName,
        lineNumber: processLineNumber(_lineNumber),
        homePhone: _homePhone,
        workPhone: _workPhone,
        cellPhone: _cellPhone,
        facebook: _facebook,
        instagram: _instagram,
        twitter: _twitter,
        tiktok: _tiktok,
        dob: _dob?.toUtc(),
        crossingDate: _crossingDate?.toUtc(),
        govtIssuedFirstName: _govtIssuedFirstName,
        govtIssuedMiddleName: _govtIssuedMiddleName,
        govtIssuedLastName: _govtIssuedLastName,
        address1: _address1,
        address2: _address2,
        city: _city,
        state: _state,
        zip: _zip,
        ethnicity: _ethnicity,
        occupation: _occupation,
        otherChapterAffiliation: _otherChapterAffiliation,
      );

      if (kDebugMode) {
        print("parsed request from user form: $newProfile");
      }

      var aUser = await apiClient?.updateExtProfileChatUser(
          authUser?.uid ?? "", context, newProfile);
      if (kDebugMode) {
        print("updated extended profile $aUser");
      }

      setStateFromExtProfile(aUser);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _alertSnackbar.showSuccessAlert(
        "Profile Updated. Now get out there in crowd.", context);
    GoRouter.of(context).go('/home');
  }

  getPhoneNumberListTile(value, String label, Function setValue) {
    var theValue = value;
    if (value == null) {
      theValue = PhoneNumber(isoCode: IsoCode.US, nsn: "");
    } else {
      theValue = PhoneNumber(isoCode: IsoCode.US, nsn: value);
    }

    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(label),
            // value == null
            //     ? Text('no date selected')
            //     : Text("${value?.toLocal()}".split(' ')[0]),
            const SizedBox(
              width: 20.0,
            ),
            SizedBox(
              height: 48,
              width: 300,
              child: PhoneFormField(
                // key: Key(label.replaceAll(" ", "-")),
                initialValue: theValue,
                // can't be supplied simultaneously
                shouldFormat: true,
                // default
                defaultCountry: IsoCode.US,
                // default
                decoration: InputDecoration(
                    labelText: label, // default to null
                    border:
                        OutlineInputBorder() // default to UnderlineInputBorder(),
                    // ...
                    ),
                validator: PhoneValidator.validMobile(),
                // default PhoneValidator.valid()
                isCountryChipPersistent: false,
                // default
                isCountrySelectionEnabled: false,
                // default
                // countrySelectorNavigator: CountrySelectorNavigator.bottomSheet(),
                // showFlagInInput: true,  // default
                // flagSize: 16,           // default
                autofillHints: [AutofillHints.telephoneNumber],
                // default to null
                enabled: true,
                // default
                autofocus: false,
                // default
                onSaved: (PhoneNumber? p) {
                  setValue(p?.nsn);
                },
                // default null
                onChanged: (PhoneNumber? p) {
                  print("phone changed: ${p?.nsn}");
                  setValue(p?.nsn);
                }, // default null
                // ... + other textfield params
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    key: ObjectKey(_myAppUser),
                    initialValue: _loginUsername,
                    enabled: false,
                    setField: (e) {
                      setState(() {
                        _loginUsername = e;
                      });
                    },
                    labelText: 'E-mail',
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(_myAppUser),
                    initialValue: _displayName,
                    setField: (e) {
                      _displayName = e;
                    },
                    labelText: 'Display Name',
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _govtIssuedFirstName ?? "",
                    setField: (e) {
                      setState(() {
                        _govtIssuedFirstName = e;
                      });
                    },
                    labelText: "First Name",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _govtIssuedMiddleName ?? "",
                    setField: (e) {
                      setState(() {
                        _govtIssuedMiddleName = e;
                      });
                    },
                    labelText: "Middle Name",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _govtIssuedLastName ?? "",
                    setField: (e) {
                      setState(() {
                        _govtIssuedLastName = e;
                      });
                    },
                    labelText: "Last Name",
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFieldWrapped(
                          isNumberInput: true,
                          key: ObjectKey(_age),
                          initialValue: _age?.toString(),
                          setField: (e) {
                            if (e != null) {
                              _age = e;
                            }
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
                          isNumberInput: true,
                          key: ObjectKey(extProfile),
                          initialValue: _weight,
                          setField: (e) {
                            if (e != null) {
                              _weight = e;
                            }
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
                        key: ObjectKey(extProfile),
                        initialValue: _height,
                        updateHeight: (newFt, newIn) {
                          setState(() {
                            _height = Height.withValues(newFt, newIn);
                          });
                        },
                      ),
                    ),
                  ]),
                ),
                ListTile(
                  title: Flex(direction: Axis.horizontal, children: [
                    Flexible(
                      child: DateInputWrapped(
                          value: _dob ?? _dob,
                          label: "Date of Birth",
                          setValue: (e) {
                            setState(() {
                              _dob = e;
                            });
                          }),
                    ),
                  ]),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _shortBio ?? "",
                    setField: (e) {
                      setState(() {
                        _shortBio = e;
                      });
                    },
                    labelText: "Short Bio",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _longBio ?? "",
                    setField: (e) {
                      setState(() {
                        _longBio = e;
                      });
                    },
                    minLines: 3,
                    maxLines: 5,
                    labelText: "Long Bio",
                  ),
                ),
                ListTile(
                  title: Column(
                    children: [
                      Text(_otherChapterAffiliation ?? ""),
                      DropdownInputWrapped(
                          value: _otherChapterAffiliation,
                          choices: const [
                            "",
                            "Alpha Iota(AI)",
                            "Lambda Zeta(LZ)",
                            "Zeta Gamma(ZG)",
                            "Lambda Mu(LM)"
                          ],
                          label: "Other Chapter Affiliation",
                          setValue: (e) {
                            setState(() {
                              _otherChapterAffiliation = e;
                            });
                          }),
                    ],
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _dopName ?? "",
                    setField: (e) {
                      setState(() {
                        _dopName = e;
                      });
                    },
                    labelText: "Dean's Name",
                  ),
                ),
                ListTile(
                  title: Flex(direction: Axis.horizontal, children: [
                    Flexible(
                      child: DateInputWrapped(
                          value: _crossingDate ?? _crossingDate,
                          label: "Date you Crossed",
                          setValue: (e) {
                            setState(() {
                              _crossingDate = e;
                            });
                          }),
                    ),
                  ]),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _entireLinesName ?? "",
                    setField: (e) {
                      setState(() {
                        _entireLinesName = e;
                      });
                    },
                    minLines: 2,
                    maxLines: 3,
                    labelText: "Entire Line's Name",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _lineName ?? "",
                    setField: (e) {
                      setState(() {
                        _lineName = e;
                      });
                    },
                    labelText: "Line Name",
                  ),
                ),
                ListTile(
                  title: Column(
                    children: [
                      Text(_lineNumber.toString() ?? "none"),
                      DropdownInputWrapped(
                        value:
                            _lineNumber != null ? _lineNumber.toString() : null,
                        choices: [null, "", "0", "1", "3", "4", "5", "6", "7"],
                        label: "Line Number",
                        setValue: (String e) {
                          setState(
                            () {
                              _lineNumber = e;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _facebook ?? "",
                    setField: (e) {
                      setState(() {
                        _facebook = e;
                      });
                    },
                    labelText: "Facebook",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _instagram ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _instagram = e;
                        },
                      );
                    },
                    labelText: "Instagram",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _twitter ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _twitter = e;
                        },
                      );
                    },
                    labelText: "Twitter",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _tiktok ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _tiktok = e;
                        },
                      );
                    },
                    labelText: "Tik Tok",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _address1,
                    setField: (e) {
                      setState(
                        () {
                          _address1 = e;
                        },
                      );
                    },
                    labelText: "Address 1",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _address2,
                    setField: (e) {
                      setState(
                        () {
                          _address2 = e;
                        },
                      );
                    },
                    labelText: "Address 2",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _city,
                    setField: (e) {
                      setState(
                        () {
                          _city = e;
                        },
                      );
                    },
                    labelText: "City",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _state,
                    setField: (e) {
                      setState(
                        () {
                          _state = e;
                        },
                      );
                    },
                    labelText: "State",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _zip,
                    setField: (e) {
                      setState(
                        () {
                          _zip = e;
                        },
                      );
                    },
                    labelText: "Zip",
                  ),
                ),
                ListTile(
                  key: Key("cell"),
                  title: getPhoneNumberListTile(
                    _cellPhone,
                    "Cell Number",
                    (e) {
                      print("setting cell number $e");
                      if (e != null) _cellPhone = e;

                      setState(() {});
                    },
                  ),
                ),
                ListTile(
                  key: Key("home"),
                  title: getPhoneNumberListTile(
                    _homePhone,
                    "Home Number",
                    (e) {
                      print("setting home number $e");
                      if (e != null) _homePhone = e;
                      setState(() {});
                    },
                  ),
                ),
                ListTile(
                  key: Key("work"),
                  title: getPhoneNumberListTile(
                    _workPhone,
                    "Work Number",
                    (e) {
                      print("setting work number $e");
                      if (e != null) _workPhone = e;
                      setState(() {});
                    },
                  ),
                ),
                ListTile(
                  title: DropdownInputWrapped(
                    value: _ethnicity ?? "",
                    choices: const [
                      "",
                      "Black",
                      "White",
                      "Asian",
                      "Latino",
                      "Other"
                    ],
                    label: "Ethnicity",
                    setValue: (e) {
                      setState(
                        () {
                          _ethnicity = e;
                        },
                      );
                    },
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _occupation,
                    setField: (e) {
                      setState(() {
                        _occupation = e;
                      });
                    },
                    labelText: "Occupation",
                  ),
                ),
                ListTile(
                  title: AnalyticsLoadingButton(
                    analyticsEventData: {
                      'username': _myAppUser?.email,
                      'height': (_height != null).toString(),
                      'weight': (_weight != null).toString(),
                      'age': (_age != null).toString(),
                      'short_bio': ((_shortBio?.length ?? 0) > 0).toString(),
                      'long_bio': ((_longBio?.length ?? 0) > 0).toString(),
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
