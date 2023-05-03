import 'dart:async';

import 'package:kookout/models/clients/api_client.dart';
import 'package:kookout/models/position.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../config/default_config.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
class GeolocationController {
  static Position? lastKnownPosition;
  static Position? currentPosition;
  static ApiClient apiClient = ApiClient(DefaultConfig.theAuthBaseUrl);
  static Timer? geolocationTimer;

  GeolocationController() {
    _recordCurrentPosition().then((theCurrentLocation) {
      if (!kIsWeb) {
        return _recordLastKnownPosition().then((theCurrentLocation) {
          currentPosition = theCurrentLocation;
          return theCurrentLocation;
        });
      } else {
        currentPosition = theCurrentLocation;
        return theCurrentLocation;
      }
    });

    geolocationTimer ??=
        Timer.periodic(const Duration(seconds: 30), (timer) async {
      // print("Location Timer went off $timer");

      var theCurrentLocation = await _recordCurrentPosition();
      if (!kIsWeb) {
        theCurrentLocation ??= await _recordLastKnownPosition();
      }
      currentPosition = theCurrentLocation;
    });
  }

  dispose() {
    geolocationTimer?.cancel();
  }

  static get theCurrentPosition {
    return currentPosition;
  }

  Future<Position?> _recordLastKnownPosition() async {
    var theLastKnownPosition = await Geolocator.getLastKnownPosition();

    if (theLastKnownPosition != null) {
      lastKnownPosition = theLastKnownPosition;
      apiClient.updatePosition(theLastKnownPosition);
    }

    return theLastKnownPosition;
  }

  static Future<Position?> _recordCurrentPosition() async {
    try {
      var theCurrentPosition = await _determinePosition();
      currentPosition = theCurrentPosition;
      apiClient.updatePosition(theCurrentPosition);
      return theCurrentPosition;
    } catch (e) {
      if (kDebugMode) {
        print("Geolocation Controller Error: $e}");
      }
      return null;
    }
  }

  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static String distanceBetween(
      Position? startPosition, SanityPosition? endPosition) {
    // print("distance between $startPosition $endPosition");
    if (startPosition != null && endPosition != null) {
      var result = Geolocator.distanceBetween(
          startPosition.latitude,
          startPosition.longitude,
          double.parse(endPosition.latitude ?? "0"),
          double.parse(endPosition.longitude ?? "0"));

      // print("distance$result");
      return (result / 1609.344).toStringAsFixed(3);
    }
    return "0";
  }
}
