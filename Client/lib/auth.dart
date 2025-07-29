import 'package:easel/feedmanager.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "login.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';

class UserProfile {
  String name;
  String id;
  bool artist;
  // Shortlist (string of artwork IDs)
  List<String> saved;
  UserProfile(this.name, this.id, this.artist, this.saved);

  bool artInSortlist(String artID) {
    return saved.contains(artID);
  }
}

class BootManager {
  BootManager();

  static UserProfile? currentUserProfile;
  static Registrant newUser = Registrant();
  static bool loginRequired = true;
  static var db = FirebaseFirestore.instance;
  static String userid = "/";

  // Calls listenining methoids on the the Auth instance for state etc.
  static void authListen() {
    WidgetsFlutterBinding.ensureInitialized();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        loginRequired = true;
      } else {
        print('User is signed in!');
        loginRequired = false;
        BootManager.getUserInfo();
      }
    });

    FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        loginRequired = true;
      } else {
        print('User is signed in!');
        BootManager.loginRequired = false;
        BootManager.getUserInfo();
      }
    });

    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        BootManager.loginRequired = true;
      } else {
        print('User is signed in!');
        BootManager.loginRequired = false;
      }
    });
  }

  // Performs initialisation of Firebase and starts listening
  static Future<bool> boot() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    BootManager.authListen();
    return true;
  }

  static Future<void> signout() async {
    FirebaseAuth.instance.signOut();
  }

  static upgradeToArtist() {
    // would take additional fields needed to enrich profile
    currentUserProfile!.artist = true;

    db.collection("users").doc(BootManager.userid).update({"artist": true});
  }

  static Future<void> deleteUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.currentUser!.delete();
    }
  }

  // Called when user submits registration form

  static Future<void> registerUser(String email, String pw) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pw);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    BootManager.createUserInfo();
  }

  // Takes uid from FBA crediential and uses it to fetch user information from firestore users collection, setting the global
  // userprofile to the parsed response
  static getUserInfo() {
    if (FirebaseAuth.instance.currentUser != null) {
      BootManager.userid = FirebaseAuth.instance.currentUser!.uid;

      // use cust metadata for when account created

      final docRef = db.collection("users").doc(userid);
      docRef.get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        BootManager.currentUserProfile = UserProfile(
          data["name"],
          BootManager.userid,
          data["artist"],
          List.from(data['saved']),
        );
      }, onError: (e) => print("Error getting document: $e"));
    }
  }

  // For new users, creates a new user info object in firestore users collection
  static createUserInfo() {
    var useruid = FirebaseAuth.instance.currentUser?.uid ?? "x";
    final newUser = <String, dynamic>{
      "name": BootManager.newUser.name,
      "last": "notprovided",
      "artist": false,
      "saved": [],
    };
    db.collection("users").doc(useruid).set(newUser);
  }
}
