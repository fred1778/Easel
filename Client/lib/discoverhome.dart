import 'dart:isolate';

import 'package:easel/FavouritesList.dart';
import 'package:easel/SubmitView.dart';
import 'package:easel/artistlist.dart';
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

enum DiscoMode { map, search }

class Discoverhome extends StatefulWidget {
  final discoEngine = DiscoveryEngine();

  @override
  State<StatefulWidget> createState() => DiscoHomeState();
}

class DiscoHomeState extends State<Discoverhome> {
  var discoMode = DiscoMode.map;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (discoMode == DiscoMode.map) DiscoverMap(engine: widget.discoEngine),
        if (discoMode == DiscoMode.search) Searchscreen(),
        Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Spacer(),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Artistlist(engine: widget.discoEngine),
                        ),
                      );
                    },
                    child: Text("Artists in this Area"),
                  ),

                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        discoMode = (discoMode == DiscoMode.map)
                            ? DiscoMode.search
                            : DiscoMode.map;
                      });
                    },

                    child: Icon(
                      discoMode == DiscoMode.map ? Icons.search : Icons.map,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DiscoverMap extends StatefulWidget {
  final DiscoveryEngine engine;
  DiscoverMap({required this.engine});
  bool firstLoad = false; // maybe use static

  @override
  State<StatefulWidget> createState() => DiscoverMapState();
}

class PointProcess extends OnPointAnnotationClickListener {
  void Function(ArtPiece)? update;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print(annotation.textField ?? "unknown");
    ArtPiece art = FeedManager.artFeed.firstWhere(
      (piece) => piece.title == annotation.textField,
    );
    if (update != null) {
      update!(art);
    }

    annotation.iconOpacity = 0.5;
  }
}

class DiscoverMapState extends State<DiscoverMap> {
  MapboxMap? map;
  bool located = false;
  PointAnnotationManager? pointManager;
  bool navigate = false;
  ArtPiece? artwork;
  Position? lastUpdatePos;

  void annotationClick(ArtPiece art) {
    setState(() {
      this.artwork = art;
      this.navigate = true;
    });
  }

  PointProcess pointProcess = PointProcess();

  void mapSetUp(MapboxMap newMap) async {
    newMap.location.updateSettings(LocationComponentSettings(enabled: true));
    this.map = newMap;
    this.pointManager = await newMap.annotations.createPointAnnotationManager();
    // pointManager?.setIconOpacity(0.5);
    pointManager?.createMulti(widget.engine.generateAnnotationList());
    pointManager?.addOnPointAnnotationClickListener(pointProcess);
  }

  void zoomMonitor(MapContentGestureContext context) {
    /*this.map!.getCameraState().then((camState) {
      if (camState.zoom < 10) {
        print("ccccccc");
        this.pointManager!.getAnno
        this,map!.
        this.pointManager!.setTextColor(Colors.amber.toARGB32());
      } else {
        this.pointManager!.setTextOpacity(1);
      }
    });*/
  }

  void nearbyUpdates(CameraChangedEventData context) {
    this.map!.getCameraState().then((camState) {
      print("evaluating disp for artist query");
      if (lastUpdatePos == null ||
          widget.engine.displacementExceeds(
            5000,
            camState.center.coordinates,
            lastUpdatePos!,
          )) {
        print("new fetch required");
        widget.engine.getArtistsInArea(camState.center.coordinates);
        lastUpdatePos = camState.center.coordinates;
      } else {
        print("insufficient camera displacement");
      }
    });
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
    pointProcess.update = annotationClick;

    if (located) {
      //if (!navigate) {

      return MapWidget(
        cameraOptions: widget.engine.startCam!,
        onMapCreated: mapSetUp,
        onZoomListener: zoomMonitor,
        onCameraChangeListener: (CameraChangedEventData context) {
          this.map!.getCameraState().then((camState) {
            print("evaluating disp for artist query");
            if (lastUpdatePos == null ||
                widget.engine.displacementExceeds(
                  5000,
                  camState.center.coordinates,
                  lastUpdatePos!,
                )) {
              print("new fetch required");
              widget.engine.getArtistsInArea(camState.center.coordinates);
              lastUpdatePos = camState.center.coordinates;
            }
          });
        },
        styleUri: "mapbox://styles/freddles/cmdd39htc00au01r19h43bs09",
        onTapListener: (mcontext) {
          if (navigate) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtWorkDetail(toDisplay: this.artwork!),
              ),
            );
            navigate = false;
          }
        },
      );
    } else {
      return Center(
        child: Text(
          "Loading Map...",
          style: GoogleFonts.playfair(fontSize: 28, color: Colors.blueGrey),
        ),
      );
    }
  }
}
