import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    BootManager.boot();
    //BootManager.authListen();
    return const MaterialApp(
      home: Scaffold(body: Center(child: LoginScreen())),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var userEmail = "";
    var userPw = "";

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Easel",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.blueGrey,
                  fontSize: 90,
                ),
                maxLines: 10,
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 80),

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
              print(value);
              userPw = value;
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
                },
                child: const Text('Register'),
              ),
            ],
          ),

          Spacer(),
        ],
      ),
    );
  }
}
