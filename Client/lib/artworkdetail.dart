import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homefeed.dart';
import 'feedmanager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ArtWorkDetail extends StatelessWidget {
  final ArtPiece toDisplay;
  const ArtWorkDetail({super.key, required this.toDisplay});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("About this Artwork"),
        titleTextStyle: GoogleFonts.playfair(color: Colors.black, fontSize: 20),
      ),
      body: Center(child: ArtDetailPane(toDisplay: toDisplay)),
    );
  }
}

class ArtWorkFrame extends StatefulWidget {
  ArtWorkFrame({super.key, required this.toDisplay});

  final ArtPiece toDisplay;
  @override
  State<StatefulWidget> createState() => ArtWorkFrameState();
}

class ArtWorkFrameState extends State<ArtWorkFrame> {
  bool textOverlay = false;
  var imgFound = false;
  var imgUrl = "";
  void updateURL(String url) {
    if (!mounted) return;
    setState(() {
      print("XXXXXXXX " + url);
      imgUrl = url;
      imgFound = true;
    });
  }

  void toggleDisplay() {
    setState(() {
      print("toggle text overlay");
      textOverlay = !textOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!imgFound && mounted) {
      FeedManager.getURLForPath(widget.toDisplay.imgPath, updateURL);
    }
    return GestureDetector(
      onTap: toggleDisplay,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (imgFound)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: imgUrl,

                    fit: BoxFit.fitHeight,
                    height: 280,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ],
              ),
            if (textOverlay)
              ColoredBox(
                color: Color.fromARGB(187, 0, 0, 0),
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Studio Notes",
                            style: GoogleFonts.playfair(
                              color: Color(0x90FFFFFF),
                              fontSize: 40,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.toDisplay.blurb,
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ArtDetailPane extends StatefulWidget {
  final ArtPiece toDisplay;
  const ArtDetailPane({super.key, required this.toDisplay});

  @override
  State<StatefulWidget> createState() => ArtPaneState();
}

class ArtPaneState extends State<ArtDetailPane> {
  var artistInfoFetched = false;
  UserProfile? user;
  void fillUser(UserProfile userData) {
    if (!artistInfoFetched) {
      setState(() {
        user = userData;
        artistInfoFetched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FeedManager.getArtInfoForArtist(widget.toDisplay.artist, fillUser);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ArtWorkFrame(toDisplay: widget.toDisplay),
        Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    widget.toDisplay.title,
                    style: GoogleFonts.playfair(
                      color: Colors.black,
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Row(
                children: [
                  if (artistInfoFetched)
                    Text(
                      user?.name ?? "d",
                      style: GoogleFonts.playfair(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  Divider(),
                  Spacer(),
                ],
              ),
              Divider(),
              ArtInfoPanel(artwork: widget.toDisplay),
            ],
          ),
        ),

        Spacer(),
        MarketPanel(artwork: widget.toDisplay),
      ],
    );
  }
}

class ArtInfoBox extends StatelessWidget {
  final String text;
  final IconData iconName;
  ArtInfoBox({super.key, required this.iconName, required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(iconName, color: Colors.blueGrey),
            SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.playfair(color: Colors.black, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtInfoPanel extends StatelessWidget {
  ArtInfoPanel({super.key, required this.artwork});
  final ArtPiece artwork;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ArtInfoBox(
          iconName: Icons.aspect_ratio,
          text: RenderingServices.dimensions(artwork.width, artwork.height),
        ),
        ArtInfoBox(iconName: Icons.palette, text: artwork.medium),

        ArtInfoBox(iconName: Icons.calendar_today, text: "2019"),
      ],
    );
  }
}

class MarketPanel extends StatelessWidget {
  MarketPanel({super.key, required this.artwork});

  final ArtPiece artwork;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Text(
                "£${artwork.price}",
                style: GoogleFonts.playfair(color: Colors.black, fontSize: 60),
              ),
              Spacer(),
              FilledButton(
                onPressed: () {
                  print("purchaed art");
                },
                child: Text("Buy", style: GoogleFonts.playfair(fontSize: 30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
