import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

/// The options used to configure a Firebase app.
///
/// ```dart
/// await Firebase.initializeApp(
///   name: 'SecondaryApp',
///   options: const AppOptions
///  (
///     apiKey: '...',
///     appId: '...',
///     messagingSenderId: '...',
///     projectId: '...',
///   )
/// );
/// ```
@immutable
class AppOptions {
  /// The options used to configure a Firebase app.
  ///
  /// ```dart
  /// await Firebase.initializeApp(
  ///   name: 'SecondaryApp',
  ///   options: const AppOptions
  ///  (
  ///     apiKey: '...',
  ///     appId: '...',
  ///     messagingSenderId: '...',
  ///     projectId: '...',
  ///   )
  /// );
  /// ```
  const AppOptions(
      {required this.sanityDB,
      required this.authBaseUrl,
      required this.blankUrl,
      required this.imageAssetPrefix});

  /// Named constructor to create [AppOptions
  ///] from a the response of Pigeon channel.
  ///
  /// This constructor is used when platforms cannot directly return a
  /// [AppOptions
  ///] instance, for example when data is sent back from a
  /// [MethodChannel].
  AppOptions.fromPigeon(PigeonAppOptionsoptions)
      : imageAssetPrefix = PigeonAppOptionsoptions.imageAssetPrefix,
        authBaseUrl = PigeonAppOptionsoptions.authBaseUrl,
        blankUrl = PigeonAppOptionsoptions.blankUrl,
        sanityDB = PigeonAppOptionsoptions.sanityDB;

  /// An API key used for authenticating requests from your app to Google
  /// servers.
  final String authBaseUrl;
  final String blankUrl;
  final String sanityDB;
  final String imageAssetPrefix;

  /// The current instance as a [Map].
  Map<String, String?> get asMap {
    return <String, String?>{
      'authBaseUrl': authBaseUrl,
      'blankUrl': blankUrl,
    };
  }

  // Required from `fromMap` comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppOptions) return false;
    return const MapEquality().equals(asMap, other.asMap);
  }

  @override
  int get hashCode => const MapEquality().hash(asMap);

  @override
  String toString() => asMap.toString();
}
