import 'package:easel/auth.dart';
import 'package:easel/homefeed.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  print("eeeee");
  await BootManager.boot();
  print("xxxx");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Easel'),
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: Colors.black,
            fontSize: 50.0,
          ),
          surfaceTintColor: Colors.white,
          centerTitle: false,
          actionsPadding: EdgeInsets.all(5),
          actions: [
            if (!BootManager.loginRequired)
              Icon(Icons.account_circle_sharp, size: 45, color: Colors.black),
          ],
        ),
        body: Center(
          child: () {
            if (BootManager.loginRequired) {
              return LoginScreen();
            }
            print(
              " && homefeed for " +
                  (FirebaseAuth.instance.currentUser?.uid ?? "d"),
            );
            return Homefeed();
          }(),
        ),
      ),
    );
  }
}

class StartSwitch extends StatefulWidget {
  const StartSwitch({super.key});

  @override
  State<StartSwitch> createState() => SwitchState();
}

class SwitchState extends State<StartSwitch> {
  var loggedIn = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: () {
        if (loggedIn) {
          return Homefeed();
        }
        return LoginScreen();
      }(),
    );
  }
}
