import 'package:easel/feedmanager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'artworkdetail.dart';
import 'homefeed.dart';
import 'SubmitView.dart';

class GenericFeed extends StatefulWidget {
  List<String>? targets;
  bool userShortlist;
  bool userArt;
  String? user;

  GenericFeed({
    super.key,
    this.targets,
    this.userShortlist = false,
    this.userArt = false,
    this.user = null,
  });

  @override
  State<StatefulWidget> createState() => GenericFeedState();
}

class GenericFeedState extends State<GenericFeed>
    with AutomaticKeepAliveClientMixin {
  int artworkCount = 0;
  bool fetched = false;
  bool popDetail = false;

  @override
  void deactivate() {
    // TODO: implement deactivate
    fetched = false;
    super.deactivate();
  }

  List<ArtPiece> artworks = [];
  void fufillArt(List<ArtPiece> art) {
    print("gen feed callback");
    setState(() {
      artworks = art;
      artworkCount = art.length;
      fetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(artworks.length.toString());
    // switch fetched to false if navigate away?

    if (!fetched) {
      print("GF fetch");
      if (widget.userShortlist) {
        print("Generic feed - getting shortlist");
        FeedManager.getShortlistForUser(fufillArt);
      } else if (widget.userArt) {
        FeedManager.getUserArt(fufillArt);
      } else if (widget.user != null) {
        FeedManager.getUserArt(fufillArt, widget.user!);
        popDetail = true; // pop back to user info not push to new one
      } else {
        FeedManager.getArtData(fufillArt);
      }
    }
    super.build(context);

    if (!artworks.isEmpty) {
      return ListView.separated(
        padding: EdgeInsets.all(10),
        itemCount: 10,
        addAutomaticKeepAlives: true,
        itemBuilder: (BuildContext context, int index) {
          if (artworkCount > index) {
            return GestureDetector(
              child: CardTest(toDisplay: artworks.elementAt(index)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ArtWorkDetail(toDisplay: artworks.elementAt(index)),
                  ),
                );
              },
            );
          }
        },
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: 15),
      );
    } else {
      return Column(
        children: [
          SizedBox(height: 30),
          Text(
            "Nothing to show here, yet...",
            style: GoogleFonts.playfair(fontSize: 30, color: Colors.grey),
          ),
          SizedBox(height: 25),
          if (widget.userArt)
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubmitView()),
                );
              },
              child: Text(
                "Tap here to post your first piece of art!",
                style: GoogleFonts.playfair(fontSize: 20, color: Colors.grey),
              ),
            ),

          Spacer(),
        ],
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
