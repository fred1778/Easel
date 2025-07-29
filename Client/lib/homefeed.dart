import 'package:easel/feedmanager.dart';
import 'package:easel/genericlist.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'artworkdetail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'genericlist.dart';

class ArtPiece {
  String artist;
  String imgPath;
  String title;
  String medium;
  int width;
  int height;
  int price;
  String blurb;
  String year;
  List<num> geoloc;

  ArtPiece(
    this.artist,
    this.imgPath,
    this.title,
    this.height,
    this.width,
    this.medium,
    this.price,
    this.blurb,
    this.geoloc,
    this.year,
  );
}

class Homefeed extends StatefulWidget {
  bool hasLaunched = false;
  Homefeed({super.key});

  @override
  State<StatefulWidget> createState() => HomefeedState();
}

class HomefeedState extends State<Homefeed> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GenericFeed();
  }
}

class CardTest extends StatefulWidget {
  final ArtPiece toDisplay;
  const CardTest({super.key, required this.toDisplay});
  @override
  State<StatefulWidget> createState() => CardTestState();
}

class CardTestState extends State<CardTest> with AutomaticKeepAliveClientMixin {
  var imgFound = false;
  var imgURL = "";
  var isShortlisted = false;
  var startStateFound = false;

  void updateURL(String url) {
    if (!imgFound && mounted) {
      setState(() {
        imgURL = url;
        imgFound = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    setState(() {
      if (!startStateFound) {
        isShortlisted =
            BootManager.currentUserProfile?.artInSortlist(
              widget.toDisplay.imgPath,
            ) ??
            false;

        startStateFound = true;
      }
    });

    if (!imgFound && mounted) {
      FeedManager.getURLForPath(widget.toDisplay.imgPath, updateURL);
    }
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(165, 96, 125, 139)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                width: 300,
                child: Flexible(
                  flex: 6,
                  child: Text(
                    widget.toDisplay.title,
                    maxLines: 3,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 2),

              IconButton(
                onPressed: () {
                  setState(() {
                    print("art in SL: " + isShortlisted.toString());

                    FeedManager.registerArtworkSave(
                      widget.toDisplay.imgPath,
                      isShortlisted,
                    );
                    isShortlisted = !isShortlisted;
                  });

                  // Calling here to make sure new SL data is propogated
                  BootManager.getUserInfo();
                },

                icon: isShortlisted
                    ? Icon(
                        Icons.bookmark,
                        color: const Color.fromARGB(255, 232, 119, 7),
                        size: 30,
                      )
                    : Icon(
                        Icons.bookmark_border,
                        color: const Color.fromARGB(255, 163, 140, 118),
                        size: 30,
                      ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.toDisplay.medium,
                style: GoogleFonts.playfairDisplay(),
              ),

              Spacer(),
            ],
          ),
          SizedBox(height: 10),
          if (imgFound)
            CachedNetworkImage(
              fadeInDuration: Duration(seconds: 2),

              imageUrl: imgURL,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RenderingServices {
  //Used to get readable multi-word labeles for enums
  static String underscoreToSpace(String str) => str.replaceAll("_", " ");

  static String dimensions(int width, int height) {
    return width.toString() + " x " + height.toString();
  }
}
