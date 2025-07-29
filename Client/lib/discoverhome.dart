import 'dart:isolate';

import 'package:easel/FavouritesList.dart';
import 'package:easel/SubmitView.dart';
import 'package:easel/genericlist.dart';
import 'package:easel/homefeed.dart';
import 'package:easel/myartlist.dart';
import 'package:easel/profileenrich.dart';

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

enum DiscoMode { map, search }

class Discoverhome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DiscoHomeState();
}

class DiscoHomeState extends State<Discoverhome> {
  var discoMode = DiscoMode.map;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (discoMode == DiscoMode.map) DiscoverMap(),

        /* SegmentedButton(
          segments: [
            ButtonSegment(
              value: DiscoMode.search,
              label: Text(
                "Search",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.blueGrey,
                  fontSize: 20,
                ),
              ),
            ),
            ButtonSegment(
              value: DiscoMode.map,
              label: Text(
                "Map",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.blueGrey,
                  fontSize: 20,
                ),
              ),
            ),
          ],
          selected: <DiscoMode>{discoMode},

          onSelectionChanged: (Set<DiscoMode> newSelection) {
            setState(() {
              discoMode = newSelection.first;
            });
          },
          expandedInsets: EdgeInsets.all(5),
          style: ButtonStyle(enableFeedback: false),
          showSelectedIcon: false,
        ),*/
      ],
    );
  }
}

class DiscoverMap extends StatefulWidget {
  final engine = DiscoveryEngine();
  bool firstLoad = false; // maybe use static

  @override
  State<StatefulWidget> createState() => DiscoverMapState();
}

class DiscoverMapState extends State<DiscoverMap> {
  MapboxMap? map;
  bool located = false;
  PointAnnotationManager? pointManager;

  void mapSetUp(MapboxMap newMap) async {
    print("xxxxxx jjjjjjjj");
    this.map = newMap;
    newMap.location.updateSettings(LocationComponentSettings(enabled: true));
    this.pointManager = await newMap.annotations.createPointAnnotationManager();
    pointManager?.setIconOpacity(0.5);
    pointManager?.createMulti(widget.engine.generateAnnotationList());
  }

  @override
  Widget build(BuildContext context) {
    if (!located && !widget.firstLoad) {
      widget.engine.locateUser(
        (status) => setState(() {
          print("location state found");
          located = status;
        }),
      );
      widget.firstLoad = true;
    }

    if (located) {
      return MapWidget(
        cameraOptions: widget.engine.startCam!,
        onMapCreated: mapSetUp,
        //  styleUri: "mapbox://styles/freddles/cmdd39htc00au01r19h43bs09",
      );
    } else {
      return Text("dddd");
    }
  }
}
