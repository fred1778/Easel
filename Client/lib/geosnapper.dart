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
  Image? response;

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
        print("sssssssss");
        response = Image.memory(img!);
        if (img != null) {
          completed(true);
        }
      });
    });
  }

  GeoSnapper(this.lon, this.lat) {
    MapboxOptions.setAccessToken(
      "pk.eyJ1IjoiZnJlZGRsZXMiLCJhIjoiY2tsODk3ZWp4MG56cTJwcjI0OXc4bWs4eSJ9.bhQgzXy1d1Fl81oGI8ktiA",
    );
    styleMan.setStyleURI("mapbox://styles/freddles/cmdd39htc00au01r19h43bs09");
  }
}

class Geosnap extends StatefulWidget {
  final ArtPiece art;
  GeoSnapper? geoSnapDriver;

  Geosnap(this.art) {
    geoSnapDriver = GeoSnapper(
      art.geoloc[1] as double,
      art.geoloc[0] as double,
    );
  }

  @override
  State<StatefulWidget> createState() => GeosnapState();
}

class GeosnapState extends State<Geosnap> {
  bool created = false;
  Image? img;

  @override
  Widget build(BuildContext context) {
    if (!created) {
      widget.geoSnapDriver!.getSnapshot((done) {
        setState(() {
          created = done;
          img = widget.geoSnapDriver!.response!;
        });
      });
    }

    return Container(
      child: created ? img : ColoredBox(color: Colors.blueAccent),
    );
  }
}
