import 'package:easel/genericlist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyArtList extends StatelessWidget {
  MyArtList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Art"),
        titleTextStyle: GoogleFonts.playfair(color: Colors.black, fontSize: 20),
      ),

      // Need to be able to refresh userprofile object to reflect shortlist changes in-session
      body: Center(child: GenericFeed(userArt: true)),
    );
  }
}
