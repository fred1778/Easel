/*import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:easel/homefeed.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:easel/feedmanager.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "login.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart' as geo;

class GeoSnapper {
  final double lon;
  final double lat;
  StyleManager styleMan = StyleManager();
  Uint8List? response;

  Snapshotter? snap;

  void getSnapshot(Function(bool) completed) {
    Snapshotter.create(
      options: MapSnapshotOptions(
        size: Size(width: 200, height: 100),
        pixelRatio: 1.0,
      ),
    ).then((snap) {
      this.snap = snap;
      this.snap!.style = styleMan;
      this.snap!.setCamera(
        CameraOptions(
          center: Point(coordinates: Position(this.lon, this.lat)),
          zoom: 10,
        ),
      );
      this.snap!.start().then((img) {
        response = img as Uint8List?;
        if (img != null) {
          completed(true);
        }
      });
    });
  }

  GeoSnapper(this.lon, this.lat) {
    styleMan.setStyleURI("mapbox://styles/freddles/cmdd39htc00au01r19h43bs09");
  }
}

class Geosnap extends StatefulWidget {
  final ArtPiece art;
  GeoSnapper? geoSnapDriver;

  Geosnap(this.art) {
    geoSnapDriver = GeoSnapper(art.latLon["lon"]!, art.latLon["lat"]!);
  }

  @override
  State<StatefulWidget> createState() => GeosnapState();
}

class GeosnapState extends State<Geosnap> {
  bool created = false;
  Uint8List data = [] as Uint8List;

  @override
  Widget build(BuildContext context) {
    if (!created) {
      widget.geoSnapDriver!.getSnapshot((done) {
        setState(() {
          created = done;
          data = widget.geoSnapDriver!.response!;
        });
      });
    }

    return Container(
      child: /*created
          ? Image.memory(data)
          : */ ColoredBox(
        color: Colors.blueAccent,
      ),
    );
  }
}
*/
