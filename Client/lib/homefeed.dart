import 'package:easel/feedmanager.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'artworkdetail.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtPiece {
  String artist;
  String imgPath;
  String title;
  String medium;
  int width;
  int height;
  int price;
  String blurb;

  ArtPiece(
    this.artist,
    this.imgPath,
    this.title,
    this.height,
    this.width,
    this.medium,
    this.price,
    this.blurb,
  );
}

class Homefeed extends StatefulWidget {
  bool hasLaunched = false;
  Homefeed({super.key});

  @override
  State<StatefulWidget> createState() => HomefeedState();
}

class HomefeedState extends State<Homefeed> with AutomaticKeepAliveClientMixin {
  int artworkCount = 0;

  List<ArtPiece> artworks = [];
  void fufillArt(List<ArtPiece> art) {
    setState(() {
      artworks = art;
      artworkCount = art.length;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    print(artworks.length.toString());
    FeedManager.getArtData(fufillArt);
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.toDisplay.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  print("pressed");
                  FeedManager.registerArtworkSave(widget.toDisplay.imgPath);
                },
                icon: Icon(Icons.bookmark),
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

class CardPanel extends StatelessWidget {
  const CardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(
          Icons.add_circle_sharp,
          color: const Color.fromARGB(148, 173, 71, 24),
          size: 36,
        ),
        Spacer(),
      ],
    );
  }
}

// detail

class RenderingServices {
  static String dimensions(int width, int height) {
    return width.toString() + " x " + height.toString();
  }
}
