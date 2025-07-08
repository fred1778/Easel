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

class FeedManager {
  static var storage = FirebaseStorage.instance;
  static final imgStorageRoot = storage.ref().child("images");
  static UserProfile? user = BootManager.currentUserProfile;
  static var db = FirebaseFirestore.instance;

  static List<ArtPiece> artFeed = [];
  static var fetchCount = 0;

  static Future<void> getURLForPath(
    String path,
    Function(String) onFind,
  ) async {
    final imgRef = imgStorageRoot.child(path);
    await imgRef.getDownloadURL().then((ref) {
      fetchCount++;
      print("*********" + fetchCount.toString());
      onFind(ref);
    });
  }

  static void getArtInfoForArtist(
    String user_id,
    Function(UserProfile) fufill,
  ) {
    final useerRef = db.collection("users").doc(user_id);
    useerRef.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      UserProfile up = UserProfile(data["name"], user_id, true);
      fufill(up);
    });
  }

  // Get all the artwork entries and then enrich with images
  static void getArtData(void Function(List<ArtPiece>) complete) {
    // use .where() for filtering
    if (artFeed.isEmpty) {
      print("getting art");
      db
          .collection("artworks")
          .get()
          .then(
            (querySnapshot) {
              for (var docSnap in querySnapshot.docs) {
                var dataMap = docSnap.data();
                print("adding art");
                artFeed.add(
                  ArtPiece(
                    dataMap["artist"],
                    docSnap.id,
                    dataMap["title"],
                    dataMap["height"],
                    dataMap["width"],
                    dataMap["medium"],
                    dataMap["price"],
                    dataMap["blurb"],
                  ),
                );
                complete(artFeed);
              }
            },
            onError: (error) {
              throw error;
            },
          );
    } else {
      complete(artFeed);
    }
  }
}
