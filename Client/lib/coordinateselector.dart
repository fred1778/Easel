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
  final ArtSubmissionData artData;
  var eeee = 333;

  Coordinateselector({super.key, required this.artData});

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
                  print("yyyy");
                  map!.getCameraState().then((cam) {
                    setState(() {
                      approved = cam.zoom >= 10 ? true : false;
                    });
                  });
                },
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(-98.0, 39.5)),
                  zoom: 10,
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
                    Icons.center_focus_strong,
                    size: 40,
                    color: approved ? Colors.deepOrange : Colors.blueGrey,
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: approved
                        ? () {
                            print("Submit");

                            map!.getCameraState().then((cam) {
                              widget.artData.geo = [
                                cam.center.coordinates.lat as double,
                                cam.center.coordinates.lng as double,
                              ];
                            });

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
