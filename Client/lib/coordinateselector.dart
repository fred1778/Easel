import 'dart:isolate';

import 'package:easel/FavouritesList.dart';
import 'package:easel/SubmitView.dart';
import 'package:easel/artworkdetail.dart';
import 'package:easel/feedmanager.dart';
import 'package:easel/genericlist.dart';
import 'package:easel/homefeed.dart';
import 'package:easel/myartlist.dart';
import 'package:easel/profileenrich.dart';
import 'package:easel/searchscreen.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'submissionmanager.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'discoveryengine.dart';

class Coordinateselector extends StatefulWidget {
  final ArtSubmissionData? artData;
  final bool? currentUserLocaleMode;
  final void Function(Point)? onLocationSelected;

  Color baseColour = Colors.blueGrey;
  Color passColour = Colors.deepOrange;

  Coordinateselector({
    super.key,
    this.artData,
    this.currentUserLocaleMode,
    this.onLocationSelected,
  });

  @override
  State<StatefulWidget> createState() => CoordinateselectorState();
}

class CoordinateselectorState extends State<Coordinateselector> {
  var mapping = DiscoveryEngine();
  var approved = false;
  MapboxMap? map;

  void mapSetUp(MapboxMap newMap) async {
    this.map = newMap;
  }

  @override
  Widget build(BuildContext context) {
    bool isLocaleSelector =
        widget.currentUserLocaleMode != null &&
        widget.currentUserLocaleMode == true;

    if (isLocaleSelector) {
      widget.baseColour = const Color.fromARGB(65, 115, 144, 158);
      widget.passColour = const Color.fromARGB(93, 191, 146, 133);
    }
    int minZoom = isLocaleSelector ? 12 : 10;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsetsDirectional.only(top: 5.0),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              MapWidget(
                onMapCreated: mapSetUp,
                onZoomListener: (mapGesture) {
                  map!.getCameraState().then((cam) {
                    setState(() {
                      approved = cam.zoom >= minZoom ? true : false;
                    });
                  });
                },
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(-1.38, 53.13)),
                  zoom: 5,
                  bearing: 0,
                  pitch: 0,
                ),
                styleUri: "mapbox://styles/freddles/cmdoo2e6o00cv01s8ds4ra0qm",
              ),

              Column(
                children: [
                  SizedBox(height: 90),
                  Text(
                    approved ? "" : "Zoom in further to confirm location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      backgroundColor: const Color.fromARGB(117, 208, 170, 57),
                    ),
                  ),
                  Spacer(),
                  Icon(
                    widget.currentUserLocaleMode != null &&
                            widget.currentUserLocaleMode == true
                        ? Icons.circle
                        : Icons.center_focus_strong,
                    size: isLocaleSelector ? 200 : 40,
                    color: approved ? widget.passColour : widget.baseColour,
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: approved
                        ? () {
                            if (!isLocaleSelector) {
                              print("Submit");

                              map!.getCameraState().then((cam) {
                                widget.artData!.geo = [
                                  cam.center.coordinates.lat as double,
                                  cam.center.coordinates.lng as double,
                                ];
                              });
                            } else {
                              //update user local
                              map!.getCameraState().then((cam) {
                                widget.onLocationSelected!(cam.center);
                              });
                            }

                            Navigator.pop(context);
                          }
                        : null,
                    child: Text("Confirm Location"),
                  ),
                  SizedBox(height: 90),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
