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

  static void registerArtworkSave(String artID, bool isDelete) {
    // art is already in saved, remove it
    var baseRef = db.collection("users").doc(BootManager.userid);

    if (isDelete) {
      baseRef
          .update({
            "saved": FieldValue.arrayRemove([artID]),
          })
          .then((value) {
            print("removed from user SL");
          });
    } else {
      baseRef
          .update({
            "saved": FieldValue.arrayUnion([artID]),
          })
          .then((value) {
            print("added to user SL");
          });
    }
  }

  static Future<void> getURLForPath(
    String path,
    Function(String) onFind,
  ) async {
    final imgRef = imgStorageRoot.child(path);
    await imgRef.getDownloadURL().then((ref) {
      onFind(ref);
    });
  }

  static Future<void> getURLsForPath(
    String path,
    String dtl_path,

    Function(Set<String>) onFind,
  ) async {
    final imgRef = imgStorageRoot.child(path);
    final imgDtlRef = imgStorageRoot.child(dtl_path);
    print("${path} and ${dtl_path}");

    String imgURL = "";

    await imgRef.getDownloadURL().then((ref) {
      fetchCount++;
      print("*********" + fetchCount.toString() + "  " + ref);
      imgURL = ref;
    });
    await imgDtlRef.getDownloadURL().then((ref) {
      onFind({imgURL, ref});
    });
  }

  static void getArtInfoForArtist(
    String user_id,
    Function(UserProfile) fufill,
  ) {
    print("IAM 000 3999");
    final useerRef = db.collection("users").doc(user_id);
    useerRef.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      print(data);
      UserProfile up = parseUser(data, user_id);
      fufill(up);
    });
  }

  static UserProfile parseUser(Map<String, dynamic> dataMap, String id) {
    UserProfile up = UserProfile(
      dataMap["name"],
      id,
      true,
      List.from(dataMap["saved"]),
      List<num>.from(dataMap["locale"]),
      dataMap["blurb"],
      dataMap['uploads'],
      dataMap['score'],
      dataMap['sanctioned'],
    );
    return up;
  }

  static ArtPiece parseArtPiece(
    QueryDocumentSnapshot<Map<String, dynamic>>? artDataQuery,
    DocumentSnapshot<Object?>? docObject,
  ) {
    Map<String, dynamic> dataMap;
    String id;

    if (docObject != null) {
      dataMap = docObject.data() as Map<String, dynamic>;
      id = docObject.id;
    } else {
      dataMap = artDataQuery!.data();
      id = artDataQuery.id;
    }

    return ArtPiece(
      dataMap["artist"],
      id,
      dataMap["title"],
      dataMap["medium"],

      dataMap["height"],
      dataMap["width"],
      dataMap["depth"],
      dataMap["price"],
      dataMap["blurb"],
      dataMap["year"],
      List<num>.from(dataMap["geoloc"]),
      dataMap["status"],
      dataMap["refer_assignee"],
    );
  }

  static void parseToArtPieceCollection(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    List<ArtPiece> collection,
  ) {
    for (var docSnap in docs) {
      print("adding art");
      collection.add(FeedManager.parseArtPiece(docSnap, null));
      ;
    }
  }

  static void getUserArt(
    void Function(List<ArtPiece>) complete, [
    String? otherUser,
  ]) {
    // use .where() for filtering
    var targetUser = (otherUser == null) ? BootManager.userid : otherUser;

    List<ArtPiece> userArt = [];

    db
        .collection("artworks")
        .where("artist", isEqualTo: targetUser)
        .get()
        .then(
          (querySnapshot) {
            FeedManager.parseToArtPieceCollection(querySnapshot.docs, userArt);
            complete(userArt);
          },
          onError: (error) {
            throw error;
          },
        );
  }

  // need to combine some of these as these funcs are very similar
  static void getShortlistForUser(void Function(List<ArtPiece>) complete) {
    List<ArtPiece> shortlist = [];
    var count = 0;

    for (var artPiece in BootManager.currentUserProfile!.saved) {
      db
          .collection("artworks")
          .doc(artPiece)
          .get()
          .then(
            (DocumentSnapshot doc) {
              count++;
              print("SL for user - item " + count.toString());

              shortlist.add(FeedManager.parseArtPiece(null, doc));
              complete(shortlist);
            },
            onError: (error) {
              print(error.toString());
            },
          );
    }
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
              FeedManager.parseToArtPieceCollection(
                querySnapshot.docs,
                artFeed,
              );
              complete(artFeed);
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
