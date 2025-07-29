import 'package:easel/feedmanager.dart';
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

// Handles submitting images to the backend

class SubmissionManager {
  static var storage = FirebaseStorage.instance;
  static final imgStorageRoot = storage.ref().child("images");
  static UserProfile? user = BootManager.currentUserProfile;
  static var db = FirebaseFirestore.instance;

  static addImage(File imgFile, ArtPiece artdata) {
    if (BootManager.currentUserProfile == null) {
      // error with no current user - should NOT happen but to be safe
      return;
    }
    // images will be uploaded with userid_timestamp name
    String imgref =
        "${BootManager.userid}_${DateTime.now().microsecondsSinceEpoch}";

    SubmissionManager.uploadFile(imgFile, imgref, artdata);
  }

  static createArtworkRecord(String path, ArtPiece artdata) {
    var artist = user?.id ?? "0";
    var timestamp = DateTime.now();

    final newArtworkRecord = <String, dynamic>{
      "title": artdata.title,
      "artist": artist,
      "medium": artdata.medium,
      "width": 100,
      "height": 100,
      "price": artdata.price,
      "blurb": artdata.blurb,
      "status": "available",
      "uploaded": timestamp,
      "geoloc": artdata.geoloc,
      "year": artdata.year,
    };
    db.collection("artworks").doc(path).set(newArtworkRecord);
  }

  // ref coords bristol 51.454010303118345, -2.6006883211148932

  static Future<void> uploadFile(
    File img,
    String path,
    ArtPiece artwork,
  ) async {
    // We can update custom metdadata but I think we should still link it to an associated record in realtime db as
    // otherwise we're kind of misuisng what metadata is. Maybe location? idk..

    try {
      await imgStorageRoot.child(path).putFile(img);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    // register artwork info
    SubmissionManager.createArtworkRecord(path, artwork);
    // pre-emptivley update feeds - is this ineffecient? Want one centralised array that different feeds can draw from, fetching new data if needed
  }
}
