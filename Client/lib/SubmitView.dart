import 'package:easel/homefeed.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'submissionmanager.dart';

class SubmitView extends StatelessWidget {
  SubmitView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(title: Text("New Artwork")),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text("Select from Device"), Spacer()],
          ),
        ),
      ),
    );
  }
}
