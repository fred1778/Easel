import 'package:easel/feedmanager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'artworkdetail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'homefeed.dart';

class GenericFeed extends StatefulWidget {
  List<String>? targets;
  bool userShortlist;
  bool userArt;

  GenericFeed({
    super.key,
    this.targets,
    this.userShortlist = false,
    this.userArt = false,
  });

  @override
  State<StatefulWidget> createState() => GenericFeedState();
}

class GenericFeedState extends State<GenericFeed>
    with AutomaticKeepAliveClientMixin {
  int artworkCount = 0;
  bool fetched = false;

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
      if (widget.userShortlist) {
        print("Generic feed - getting shortlist");
        FeedManager.getShortlistForUser(fufillArt);
      } else if (widget.userArt) {
        FeedManager.getUserArt(fufillArt);
      } else {
        FeedManager.getArtData(fufillArt);
      }
    }
    super.build(context);
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
  }

  @override
  bool get wantKeepAlive => true;
}
