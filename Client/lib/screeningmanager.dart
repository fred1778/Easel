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
import 'feedmanager.dart';

class Screeningmanager {
  static ArtPiece? candidate;

  static void getCandidate(Function(bool) found) {
    List<ArtPiece> userArt = [];
    var db = FirebaseFirestore.instance;
    db
        .collection("artworks")
        .where("status", isEqualTo: "referred")
        .get()
        .then(
          (querySnapshot) {
            FeedManager.parseToArtPieceCollection(querySnapshot.docs, userArt);
            if (userArt.isEmpty) {
              found(false);
            } else {
              candidate = userArt.first;
              found(true);
            }
          },
          onError: (error) {
            throw error;
          },
        );
  }
}
