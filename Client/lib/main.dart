import 'package:easel/auth.dart';
import 'package:easel/homefeed.dart';
import 'package:easel/userhome.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tabbar.dart';

void main() async {
  print("eeeee");
  await BootManager.boot();
  print("xxxx");
  runApp(const MainApp());
}

const profileRoute = '/profile';

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<StatefulWidget> createState() => MainState();
}

class MainState extends State<MainApp> {
  int tabIndex = 0;
  var pageTitles = ["Easel", "Profile"];
  var login = !BootManager.loginRequired;

  void updateLoginState(bool newState) {
    setState(() {
      login = newState;
    });
    if (!login) {
      // Snap back to first tab (which will be login/reg in this state)
      changeIndex(0);
    }
  }

  void changeIndex(int newIndex) {
    setState(() {
      tabIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: login
            ? TabBarFrame(tabChange: changeIndex)
            : Text("-"),
        appBar: AppBar(
          title: Text(pageTitles[tabIndex]),
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: Colors.blueGrey,
            fontSize: 50.0,
          ),
          surfaceTintColor: Colors.white,
          centerTitle: false,
          actionsPadding: EdgeInsets.all(5),
        ),
        body: <Widget>[
          Center(
            child: () {
              if (BootManager.loginRequired) {
                return LoginScreen(change: updateLoginState);
              }
              return Homefeed();
            }(),
          ),
          Userhome(logout: updateLoginState),
        ][tabIndex],
      ),
    );
  }
}

/*class StartSwitch extends StatefulWidget {
  const StartSwitch({super.key, required this.login});
  final void Function(bool) login;

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
*/
