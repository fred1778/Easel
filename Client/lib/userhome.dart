import 'dart:isolate';

import 'package:easel/FavouritesList.dart';
import 'package:easel/SubmitView.dart';
import 'package:easel/genericlist.dart';
import 'package:easel/homefeed.dart';
import 'package:easel/myartlist.dart';
import 'package:easel/profileenrich.dart';
import 'package:easel/screeningtask.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'submissionmanager.dart';

class Userhome extends StatefulWidget {
  const Userhome({super.key, required this.logout});
  final void Function(bool) logout;

  @override
  State<StatefulWidget> createState() => UserhomeState();
}

class UserhomeState extends State<Userhome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 18,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(
                Icons.account_circle,
                size: 45,
                color: const Color.fromARGB(255, 205, 116, 27),
              ),
              Text(
                BootManager.currentUserProfile!.name,
                maxLines: 3,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black,
                  fontSize: 30.0,
                ),
              ),
              Spacer(),
            ],
          ),
          Divider(),

          SubmissionPoint(),

          StandardAction(
            onPush: () {
              print("fav push");

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Favouriteslist()),
              );
            },
            symbol: Icon(Icons.bookmark_border, size: 25),
            label: "My Shortlist",
            secondaryInformation: BootManager.currentUserProfile!.saved.length
                .toString(),
            chevron: true,
            context: context,
          ),

          StandardAction(
            onPush: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyArtList()),
              );
            },
            symbol: Icon(Icons.color_lens_outlined, size: 25),
            label: "My Art",
            chevron: true,
            context: context,
          ),

          if (BootManager.currentUserProfile!.score > 99)
            StandardAction(
              onPush: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Screeningtask()),
                );
              },
              symbol: Icon(Icons.preview_outlined),
              label: "Screening Tasks",
              chevron: true,
              context: context,
            ),

          Spacer(),
          StandardAction(
            onPush: () {
              print("so push");

              BootManager.signout();
              widget.logout(false);
            },
            symbol: Icon(
              Icons.logout,
              size: 25,
            ), // should have size defined in StandardAction, and just pass icondata
            label: "Sign Out",
            chevron: false,
            context: context,
          ),
        ],
      ),
    );
  }
}

class SubmissionPoint extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SubmissionPointState();
}

class SubmissionPointState extends State<SubmissionPoint> {
  var isArtist = BootManager.currentUserProfile!.artist;

  @override
  Widget build(BuildContext context) {
    setState(() {
      print("call profile " + isArtist.toString());
      isArtist = BootManager.currentUserProfile!.artist;
    });

    if (!isArtist) {
      return Column(
        children: [
          Text(
            "Want to sell your art?",
            style: GoogleFonts.playfair(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Complete your profile to get started...",
            style: GoogleFonts.playfair(fontSize: 20),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // expand out builder fintion to do condition in there
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEnrich()),
              ).then((value) {
                BootManager.getUserInfo();
                setState(() {
                  isArtist = BootManager.currentUserProfile!.artist;
                });
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(Colors.blueGrey),
            ),
            child: Container(
              child: Row(
                children: [
                  Spacer(),
                  Column(
                    children: [
                      Text(
                        "Complete your profile",
                        style: GoogleFonts.playfair(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 243, 243, 243),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Spacer(),
          FloatingActionButton.extended(
            backgroundColor: Colors.blueGrey,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubmitView()),
              );
            },
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              "New Art",
              style: GoogleFonts.playfair(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
  }
}

class StandardAction extends StatelessWidget {
  final Function() onPush;
  final Icon symbol;
  final String label;
  final String? secondaryInformation;
  final bool chevron;
  final BuildContext context;

  StandardAction({
    required this.onPush,
    required this.symbol,
    required this.label,
    this.secondaryInformation,
    required this.chevron,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ElevatedButton(
      onPressed: () {
        print("pressed");
        onPush();
      },
      child: Container(
        padding: EdgeInsetsDirectional.only(top: 20, bottom: 20),
        child: Row(
          spacing: 20,
          children: [
            symbol,
            Text(
              label,
              style: GoogleFonts.playfair(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            if (secondaryInformation != null) Text(secondaryInformation!),
            if (chevron) Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
