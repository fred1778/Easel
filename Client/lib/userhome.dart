import 'package:easel/SubmitView.dart';
import 'package:easel/homefeed.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'submissionmanager.dart';

class Userhome extends StatelessWidget {
  const Userhome({super.key, required this.logout});
  final void Function(bool) logout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                BootManager.currentUserProfile!.name,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black,
                  fontSize: 50.0,
                ),
              ),
              Spacer(),
              OutlinedButton(
                onPressed: () {
                  BootManager.signout();
                  logout(false);
                },
                child: Icon(Icons.logout),
              ),
            ],
          ),
          Divider(),

          //TODO: turn into generic button widget for use elsehwere
          OutlinedButton(
            onPressed: () {
              print("show faves");
            },
            child: Container(
              padding: EdgeInsetsDirectional.only(top: 25, bottom: 25),
              child: Row(
                children: [
                  Icon(Icons.bookmark),
                  Text("Favourites"),
                  Spacer(),
                  Text(
                    BootManager.currentUserProfile!.saved?.length.toString() ??
                        "0",
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),

          Spacer(),

          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubmitView()),
              );
            },
            child: Text("Submit Art"),
          ),
        ],
      ),
    );
  }
}
