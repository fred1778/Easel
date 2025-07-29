import 'package:easel/homefeed.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "login.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class Searchscreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchScreenState();
}

class SearchScreenState extends State<Searchscreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        spacing: 6,
        children: [
          TextField(
            style: GoogleFonts.playfair(),
            onSubmitted: (String value) {
              print(value);
            },
            textInputAction: TextInputAction.search,
            obscureText: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              labelText: "Search for art",
              labelStyle: GoogleFonts.playfair(),
            ),
          ),
        ],
      ),
    );
  }
}
