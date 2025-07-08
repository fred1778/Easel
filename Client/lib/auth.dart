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
  Set<String>? works;

  UserProfile(this.name, this.id, this.artist);
}

class BootManager {
  BootManager();

  static UserProfile? currentUserProfile;

  static Registrant newUser = Registrant();
  static bool loginRequired = true;
  static var db = FirebaseFirestore.instance;
  static String userid = "/";

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

  static Future<bool> boot() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("startup complete");
    BootManager.authListen();
    //  FeedManager.getArtData();

    return true;
  }

  static Future<void> signout() async {
    FirebaseAuth.instance.signOut();
  }

  static Future<void> deleteUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.currentUser!.delete();
    }
  }

  static Future<void> registerUser(String email, String pw) async {
    print("Attempting user reg with " + email + " and pw " + pw);

    try {
      print("new account created");

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

  static getUserInfo() {
    // Used to get user information based on user UID...
    if (FirebaseAuth.instance.currentUser != null) {
      BootManager.userid = FirebaseAuth.instance.currentUser!.uid;

      final docRef = db.collection("users").doc(userid);
      docRef.get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        BootManager.currentUserProfile = UserProfile(
          data["name"],
          BootManager.userid,
          false,
        );
      }, onError: (e) => print("Error getting document: $e"));
    }
  }

  static createUserInfo() {
    var useruid = FirebaseAuth.instance.currentUser?.uid ?? "x";
    final newUser = <String, dynamic>{
      "name": BootManager.newUser.name,
      "last": "notprovided",
    };
    db.collection("users").doc(useruid).set(newUser);
  }
}
