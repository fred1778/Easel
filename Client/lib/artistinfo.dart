import 'package:easel/auth.dart';
import 'package:easel/discoverhome.dart';
import 'package:easel/discoveryengine.dart';
import 'package:easel/genericlist.dart';
import 'package:easel/geosnapper.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homefeed.dart';
import 'feedmanager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class Artistinfo extends StatefulWidget {
  final UserProfile artist;
  Artistinfo({super.key, required this.artist});

  @override
  State<StatefulWidget> createState() => ArtistinfoState();
}

class ArtistinfoState extends State<Artistinfo> {
  String location = "-";

  @override
  Widget build(BuildContext context) {
    if (location == "-") {
      print("zlll" + (widget.artist.blurb ?? "nil"));
      DiscoveryEngine.reverseGeocode(
        Position(
          widget.artist.locale?[1] ?? 1.0,
          widget.artist.locale?[0] ?? 50.0,
        ),
        (found) {
          setState(() {
            location = found;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("About this Artist"),
        titleTextStyle: GoogleFonts.playfair(color: Colors.black, fontSize: 24),
      ),
      body: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              children: [
                Text(
                  widget.artist.name,
                  style: GoogleFonts.playfair(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Icon(Icons.event_available, color: Colors.blueGrey),

                Text(
                  "Joined Aug 2025",
                  style: GoogleFonts.playfair(
                    fontSize: 23,
                    color: const Color.fromARGB(255, 93, 93, 93),
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.location_on, color: Colors.blueGrey),
                Text(
                  location,
                  style: GoogleFonts.playfair(
                    fontSize: 23,
                    color: const Color.fromARGB(255, 93, 93, 93),
                  ),
                ),
                Spacer(),
              ],
            ),
            Text(
              widget.artist.blurb ?? "...",
              style: GoogleFonts.playfair(fontSize: 19),
            ),
            SizedBox(height: 35),

            Divider(),

            Text(
              "${widget.artist.name}'s work:",
              style: GoogleFonts.playfair(fontSize: 19),
            ),

            Flexible(child: GenericFeed(user: widget.artist.id)),

            //  SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
