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
import 'SubmitView.dart';

// Handles submitting images to the backend
class ArtSubmissionData {
  var title = "";
  var blurb = "";
  var price = 100.0;
  var mediumApp = ApplicationMed.values.first;
  var mediumBase = BaseMed.values.first;
  File? img;
  File? imgDtl;
  var artWidth = 100;
  var artLength = 100;
  var artDepth = 10;
  var artYear = "2025";
  var geo = [0.0, 0.0];

  bool readyToSubmit() {
    return !(img == null || img == null || title == "" || blurb == "");
  }
}

class SubmissionManager {
  static var storage = FirebaseStorage.instance;
  static final imgStorageRoot = storage.ref().child("images");
  static UserProfile? user = BootManager.currentUserProfile;
  static var db = FirebaseFirestore.instance;
  static var imgref = "";
  static var imgrefDtl = "";

  static addImage(File imgFile, File imgdtFile) {
    if (BootManager.currentUserProfile == null) {
      // error with no current user - should NOT happen but to be safe
      return;
    }
    final time = DateTime.now().microsecondsSinceEpoch;

    // images will be uploaded with userid_timestamp name
    imgref = "${BootManager.userid}_${time}";

    SubmissionManager.uploadFile(imgFile, imgdtFile, imgref);
  }

  // NEW single submission point - called by view, handles the rest using other class methods

  static submitArtData(ArtSubmissionData submission) {
    var artist = user?.id ?? "0";
    var timestamp = DateTime.now();

    addImage(submission.img!, submission.imgDtl!);
    var med = "${submission.mediumApp.name} on ${submission.mediumBase.name}";

    final newArtworkRecord = <String, dynamic>{
      "title": submission.title,
      "artist": artist,
      "medium": med,
      "width": submission.artWidth,
      "depth": submission.artDepth,
      "height": submission.artLength,
      "price": submission.price,
      "blurb": submission.blurb,
      "status": "A",
      "uploaded": timestamp,
      "geoloc": submission.geo,
      "year": submission.artYear,
      "refer_assignee": "",
    };
    db.collection("artworks").doc(imgref).set(newArtworkRecord);
  }

  static Future<void> uploadFile(
    File img,
    File imgDtl,
    String path,

    // ArtPiece artwork,
  ) async {
    // We can update custom metdadata but I think we should still link it to an associated record in realtime db as
    // otherwise we're kind of misuisng what metadata is. Maybe location? idk..
    String dtlPath = "${path}_dtl";
    try {
      await imgStorageRoot.child(path).putFile(img);
    } on FirebaseException catch (e) {
      print(e.code);
    }

    try {
      await imgStorageRoot.child(dtlPath).putFile(imgDtl);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    // register artwork info
    // SubmissionManager.createArtworkRecord(path, artwork);
    // pre-emptivley update feeds - is this ineffecient? Want one centralised array that different feeds can draw from, fetching new data if needed
  }
}
