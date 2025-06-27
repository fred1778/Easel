import 'package:easel/homefeed.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';

enum LoginType { register, login }

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
  const LoginScreen({super.key});

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

    return Container(
      padding: EdgeInsets.all(10),
      child: () {
        if (!complete) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 35),

              SegmentedButton(
                segments: [
                  ButtonSegment(
                    value: LoginType.login,
                    label: Text(
                      "Login",
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.blueGrey,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: LoginType.register,
                    label: Text(
                      "Join Easel",
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.blueGrey,
                        fontSize: 20,
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
                onSubmitted: (String value) {
                  print(value);

                  userEmail = value;
                },

                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  labelText: 'Email',
                  labelStyle: GoogleFonts.playfair(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                style: GoogleFonts.playfair(),
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
                  labelStyle: GoogleFonts.playfair(),
                ),
              ),

              Row(
                children: [
                  Spacer(),
                  FilledButton(
                    onPressed: () {
                      print("current context email is ${userEmail}pw $userPw");
                      BootManager.registerUser(userEmail, userPw);
                      setState(() {
                        complete = true;
                      });
                    },
                    child: const Text('Go'),
                  ),
                ],
              ),

              Spacer(),
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

          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            labelText: 'Name',
            labelStyle: GoogleFonts.playfair(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
