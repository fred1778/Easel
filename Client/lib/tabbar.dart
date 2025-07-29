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

class TabBarFrame extends StatefulWidget {
  const TabBarFrame({super.key, required this.tabChange});
  final void Function(int) tabChange;

  @override
  State<StatefulWidget> createState() => TabsState();
}

class TabsState extends State<TabBarFrame> with AutomaticKeepAliveClientMixin {
  int current_index = 0;
  bool enable = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          current_index = index;
          widget.tabChange(index);
        });
      },
      selectedIndex: current_index,

      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home, color: Colors.blueGrey, size: 30),
          label: "Gallery",
        ),

        NavigationDestination(
          icon: Icon(Icons.map_sharp, color: Colors.blueGrey, size: 30),
          label: "Discover",
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle, color: Colors.blueGrey, size: 30),
          label: "My Studio",
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
