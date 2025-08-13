import 'package:easel/homefeed.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';

enum LoginType { register, login }

enum UserType { artist, browser }

class Registrant {
  Registrant();

  var name = "";
  var isArtist = false;

  var email = "";
  var password = "";

  bool ready() {
    return (email != "" && password != "");
  }
}

class LoginScreen extends StatefulWidget {
  final void Function(bool) change;
  const LoginScreen({super.key, required this.change});

  @override
  State<LoginScreen> createState() => LoginState();
}

class LoginState extends State<LoginScreen> {
  var type = LoginType.login;
  var complete = false;

  void checkLoginStatus() {
    setState(() {
      print("ddddd30003");
    });
  }

  @override
  Widget build(BuildContext context) {
    var userEmail = "";
    var userPw = "";
    UserType userType = UserType.browser;

    return Container(
      padding: EdgeInsets.all(10),
      child: () {
        if (!complete) {
          return Stack(
            children: [
              /*Column(
                children: [
                  Image.asset(
                    "images/eslback.png",
                    opacity: AlwaysStoppedAnimation(0.1),
                    height: 300,
                    width: 200,
                  ),
                  Spacer(),
                ],
              ),*/
              Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Row(
                    children: [
                      Text(
                        "Art by everyone, art for everyone",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.blueGrey,
                          fontSize: 25,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 25),

                  SegmentedButton(
                    segments: [
                      ButtonSegment(
                        value: LoginType.login,
                        label: Text(
                          "Login",
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,

                            fontSize: 24,
                          ),
                        ),
                      ),
                      ButtonSegment(
                        value: LoginType.register,
                        label: Text(
                          "Join Easel",
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                    selected: <LoginType>{type},
                    onSelectionChanged: (Set<LoginType> newSelection) {
                      checkLoginStatus();
                      setState(() {
                        type = newSelection.first;
                      });
                    },
                    expandedInsets: EdgeInsets.all(5),
                    style: ButtonStyle(enableFeedback: false),
                    showSelectedIcon: false,
                  ),
                  SizedBox(height: 30),
                  if (type == LoginType.register) RegistrantInfo(),

                  TextField(
                    style: GoogleFonts.playfair(),
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (String value) {
                      userEmail = value;
                    },

                    onChanged: (String value) {
                      userEmail = value;
                      print(userEmail);
                    },
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Email',

                      labelStyle: GoogleFonts.playfair(fontSize: 22),
                    ),
                  ),
                  SizedBox(height: 22),
                  TextField(
                    style: GoogleFonts.playfair(fontSize: 22),
                    onChanged: (String value) {
                      userPw = value;
                      print(userPw);
                    },
                    onSubmitted: (String value) {
                      userPw = value;
                      print("_____ " + userPw);
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      labelText: 'Password',
                      labelStyle: GoogleFonts.playfair(fontSize: 22),
                    ),
                  ),

                  Spacer(),
                  Row(
                    children: [
                      Spacer(),
                      FilledButton(
                        onPressed: () {
                          print(
                            "current context email is ${userEmail}pw $userPw",
                          );
                          BootManager.registerUser(userEmail, userPw);
                          widget.change(true);
                          setState(() {
                            complete = true;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              'Go',
                              style: GoogleFonts.playfair(fontSize: 36),
                            ),
                            SizedBox(width: 20),
                            Icon(Icons.arrow_forward, size: 36),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }
        return Homefeed();
      }(),
    );
  }
}

class RegistrantInfo extends StatelessWidget {
  const RegistrantInfo({super.key});

  @override
  Widget build(BuildContext context) {
    var name = "";
    var artist = false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          style: GoogleFonts.playfair(),
          onSubmitted: (String value) {
            name = value;
            BootManager.newUser.name = value;
          },
          onChanged: (value) {
            name = value;
            BootManager.newUser.name = value;
          },

          obscureText: false,

          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            labelText: 'Name',
            labelStyle: GoogleFonts.playfair(fontSize: 22),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
