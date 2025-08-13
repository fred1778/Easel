import 'package:cached_network_image/cached_network_image.dart';
import 'package:easel/FavouritesList.dart';
import 'package:easel/SubmitView.dart';
import 'package:easel/artworkdetail.dart';
import 'package:easel/coordinateselector.dart';
import 'package:easel/genericlist.dart';
import 'package:easel/homefeed.dart';
import 'package:easel/screeningmanager.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'submissionmanager.dart';
import 'userhome.dart';
import 'screeningmanager.dart';

class Screeningtask extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScreeningtaskState();
}

class ScreeningtaskState extends State<Screeningtask> {
  var isFound = false;
  var ready = false;

  @override
  Widget build(BuildContext context) {
    if (!isFound) {
      Screeningmanager.getCandidate((wasfound) {
        setState(() {
          ready = wasfound;
        });
      });

      isFound = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Screening Tasks"),
        titleTextStyle: GoogleFonts.playfair(color: Colors.black, fontSize: 20),
      ),

      // Need to be able to refresh userprofile object to reflect shortlist changes in-session
      body: Center(
        child: () {
          if (ready) {
            return Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  ArtWorkFrame(toDisplay: Screeningmanager.candidate!),

                  Text(
                    "Title: ${Screeningmanager.candidate!.title} \n Size: ${RenderingServices.dimensions(Screeningmanager.candidate!.width as int, Screeningmanager.candidate!.height as int)}",
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    "Medium: ${Screeningmanager.candidate!.medium} \n Price: £${Screeningmanager.candidate!.price}",
                    style: TextStyle(fontSize: 24),
                  ),
                  Spacer(),
                  Divider(),
                  Text(
                    "Look carefully at the images and associated information. If the images look AI generated, if the images/information is incosistent or incomplete, reject the submission ",
                  ),

                  Row(
                    children: [
                      Spacer(),
                      Icon(Icons.cancel, color: Colors.red, size: 100),
                      Spacer(),
                      Icon(Icons.check_circle, color: Colors.green, size: 100),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 100),
                ],
              ),
            );
          }
        }(),
      ),
    );
  }
}
