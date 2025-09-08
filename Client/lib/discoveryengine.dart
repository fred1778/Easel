import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:easel/feedmanager.dart';
import 'dart:ui';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "login.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:geolocator/geolocator.dart' as geo;

class DiscoveryEngine {
  List<UserProfile> nearby = [];

  static String reverseGeocode(Position coords, Function(String) found) {
    print("discoeng search");
    String locRequest = "longitude=${coords.lng}&latitude=${coords.lat}";
    String filter = "&limit=1&types=place";
    String access_token_str =
        "&access_token=pk.eyJ1IjoiZnJlZGRsZXMiLCJhIjoiY2tsODk3ZWp4MG56cTJwcjI0OXc4bWs4eSJ9.bhQgzXy1d1Fl81oGI8ktiA";
    String geoURL =
        "https://api.mapbox.com/search/geocode/v6/reverse?${locRequest}${filter}${access_token_str}";

    print(geoURL);

    http.get(Uri.parse(geoURL)).then((locResponse) {
      final responseMap = jsonDecode(locResponse.body) as Map<String, dynamic>;
      final f = responseMap["features"];
      print(f);
      print(geoURL);

      found(f[0]["properties"]["name"]);

      return "dd";
    });
    return "ee";
  }

  bool displacementExceeds(double threshold, Position posA, Position posB) {
    double disp = geo.Geolocator.distanceBetween(
      posA.lat as double,
      posA.lng as double,
      posB.lat as double,
      posB.lng as double,
    );
    print(
      "DISP THRESH ${threshold.toString()} ----  ${posA.lat.toString()}  AND ${posB.lat.toString()} IS ${disp.toString()}",
    );

    return disp > threshold;
  }

  void getArtistsInArea(Position coordinates) {
    // get artists from FBF where artist flag == true

    // flush the list
    nearby.clear();

    var db = FirebaseFirestore.instance;

    db
        .collection("users")
        .where(
          "artist",
          isEqualTo: true,
        ) //999 is the default value for geoloc indicating
        .get()
        .then(
          (querySnapshot) {
            for (QueryDocumentSnapshot doc in querySnapshot.docs) {
              var usr = FeedManager.parseUser(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              if (!displacementExceeds(
                10000,
                Position(usr.locale![1], usr.locale![0]),
                coordinates,
              )) {
                if (!nearby.contains(usr)) {
                  nearby.add(usr);
                  print("user added");
                }
              }
            }
          },
          onError: (error) {
            throw error;
          },
        );
  }

  geo.Position? userPos;
  CameraOptions? startCam;
  bool currentLocationReady = false;
  Uint8List? marker;

  Future<geo.Position> _determinePosition() async {
    markerImgData();
    bool serviceEnabled;
    geo.LocationPermission permission;
    // Test if location serices are enabled.
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await geo.Geolocator.getCurrentPosition();
  }

  void markerImgData() async {
    final ByteData bd = await rootBundle.load("images/trim5.png");
    this.marker = bd.buffer.asUint8List();
  }

  List<PointAnnotationOptions> generateAnnotationList() {
    // Just take the preloaded list from the generic feed query to save re-calling, might hang if user goes straight to this map but thats for later
    List<PointAnnotationOptions> artPoints = [];

    for (var artwork in FeedManager.artFeed) {
      var dd = PointAnnotationOptions(
        iconSize: 0.9,

        textSize: 12,
        textColor: Colors.black.toARGB32(),
        textOffset: [0, 1.2],
        textOpacity: 0.0, // need the title, don't want to display it
        textField: artwork.title,
        geometry: Point(
          coordinates: Position(artwork.geoloc[1], artwork.geoloc[0]),
        ),
        image: this.marker!,
        iconOpacity: 1,
        iconEmissiveStrength: 1,
      );
      artPoints.add(dd);
    }

    return artPoints;
  }

  void locateUser(Function(bool) onComplete) {
    _determinePosition().then((pos) {
      userPos = pos;
      startCam = CameraOptions(
        center: Point(
          coordinates: Position(userPos!.longitude, userPos!.latitude),
        ),
        zoom: 12.0,
      );
      onComplete(true);
    });
  }

  DiscoveryEngine() {
    String ACCESS_TOKEN =
        "pk.eyJ1IjoiZnJlZGRsZXMiLCJhIjoiY21kZDJkMzg3MDBiejJrczNpNnlyNjFmdiJ9.rVKYXkyvFIELcLVt4szyoQ";
    MapboxOptions.setAccessToken(ACCESS_TOKEN);
    print("engine loaded");
  }
}
