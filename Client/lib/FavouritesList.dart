import 'package:easel/feedmanager.dart';
import 'package:easel/genericlist.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'artworkdetail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'genericlist.dart';

class Favouriteslist extends StatelessWidget {
  Favouriteslist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shortlist"),
        titleTextStyle: GoogleFonts.playfair(color: Colors.black, fontSize: 20),
      ),

      // Need to be able to refresh userprofile object to reflect shortlist changes in-session
      body: Center(child: GenericFeed(userShortlist: true)),
    );
  }
}
