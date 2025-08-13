import 'package:easel/artistinfo.dart';
import 'package:easel/discoveryengine.dart';
import 'package:easel/feedmanager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'artworkdetail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'homefeed.dart';

class ArtistRow extends StatelessWidget {
  final UserProfile artist;
  ArtistRow({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: Colors.blueGrey,
          width: 1,
          style: BorderStyle.solid,
          strokeAlign: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(5),
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.person, color: Colors.blueGrey),
          Text(artist.name, style: GoogleFonts.playfair(fontSize: 35)),
          Spacer(),
          Text(artist.artMedium?.first.toString() ?? ""),
        ],
      ),
    );
  }
}

class Artistlist extends StatefulWidget {
  final DiscoveryEngine engine;
  Artistlist({required this.engine});

  @override
  State<StatefulWidget> createState() => ArtistListState();
}

class ArtistListState extends State<Artistlist>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Local Artists", style: GoogleFonts.playfair()),
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: ListView.separated(
          padding: EdgeInsets.all(10),
          itemCount: 10,
          addAutomaticKeepAlives: true,
          itemBuilder: (BuildContext context, int index) {
            if (widget.engine.nearby.length > index) {
              return GestureDetector(
                child: ArtistRow(artist: widget.engine.nearby.elementAt(index)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Artistinfo(
                        artist: widget.engine.nearby.elementAt(index),
                      ),
                    ),
                  );
                },
              );
            }
          },
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 15),
        ),
      ),
    );
  }
}
