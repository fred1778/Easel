import 'package:easel/SubmitView.dart';
import 'package:easel/artistinfo.dart';
import 'package:easel/auth.dart';
import 'package:easel/geosnapper.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homefeed.dart';
import 'feedmanager.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtWorkDetail extends StatelessWidget {
  final ArtPiece toDisplay;
  final bool? popBack;
  const ArtWorkDetail({super.key, required this.toDisplay, this.popBack});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("About this Artwork"),
        titleTextStyle: GoogleFonts.playfair(color: Colors.black, fontSize: 25),
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
  var dtlUrl = "";

  ImgTypes imgType = ImgTypes.main;

  void updateURL(Set<String> urls) {
    if (!mounted) return;
    setState(() {
      imgUrl = urls.first;
      dtlUrl = urls.elementAt(1);
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
      FeedManager.getURLsForPath(
        widget.toDisplay.imgPath,
        "${widget.toDisplay.imgPath}_dtl",
        updateURL,
      );
    }
    return Column(
      children: [
        GestureDetector(
          onTap: toggleDisplay,
          child: Container(
            color: (imgType == ImgTypes.main || imgType == ImgTypes.detail)
                ? Colors.black
                : Colors.white,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (imgFound)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: () {
                          if (imgType == ImgTypes.main ||
                              imgType == ImgTypes.detail) {
                            return CachedNetworkImage(
                              imageUrl: imgType == ImgTypes.main
                                  ? imgUrl
                                  : dtlUrl,

                              fit: BoxFit.fitHeight,
                              height: 320,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            );
                          } else if (imgType == ImgTypes.story) {
                            return Container(
                              padding: EdgeInsets.all(20),
                              height: 300,
                              child: Text(
                                "\"${widget.toDisplay.blurb}\"",
                                style: GoogleFonts.playfair(fontSize: 30),
                              ),
                            );
                          } else {
                            return Image.asset("images/wall.png");
                          }
                        }(),
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
        ),

        SegmentedButton(
          segments: [
            ButtonSegment(
              value: ImgTypes.main,
              icon: Icon(Icons.image_outlined),
              label: Text("Full", style: GoogleFonts.playfair()),
            ),
            ButtonSegment(
              value: ImgTypes.detail,
              icon: Icon(Icons.pageview_outlined),
              label: Text("Detail", style: GoogleFonts.playfair()),
            ),
            ButtonSegment(
              value: ImgTypes.wall,
              icon: Icon(Icons.picture_in_picture_alt_outlined),
              label: Text("Room", style: GoogleFonts.playfair()),
            ),

            ButtonSegment(
              value: ImgTypes.story,
              icon: Icon(Icons.format_quote_outlined),
              label: Text("Studio Notes", style: GoogleFonts.playfair()),
            ),
          ],
          selected: <ImgTypes>{imgType},
          onSelectionChanged: (selection) {
            setState(() {
              imgType = selection.first;
            });
          },
        ),
      ],
    );
  }
}

class ImageToggleBar extends StatefulWidget {
  Function(ImgTypes) setShow;
  ImageToggleBar({required this.setShow});

  @override
  State<StatefulWidget> createState() => ImageTogBarState();
}

class ImageTogBarState extends State<ImageToggleBar> {
  var selection = ImgTypes.main;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text("d")]);
  }
}

class ArtDetailPane extends StatefulWidget {
  final ArtPiece toDisplay;
  final bool? pop;

  const ArtDetailPane({super.key, required this.toDisplay, this.pop});

  @override
  State<StatefulWidget> createState() => ArtPaneState();
}

class ArtPaneState extends State<ArtDetailPane> {
  var artistInfoFetched = false;
  UserProfile? user;

  void fillUser(UserProfile userData) {
    if (!artistInfoFetched) {
      setState(() {
        print("--------");
        print(userData.name);

        print(userData.locale);
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
                  Flexible(
                    flex: 6,
                    child: Text(
                      widget.toDisplay.title,
                      style: GoogleFonts.playfair(
                        color: Colors.black,
                        fontSize: 32,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  if (artistInfoFetched)
                    GestureDetector(
                      onTap: () {
                        if (widget.pop == null || widget.pop == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Artistinfo(artist: user!),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        user?.name ?? "d",
                        style: GoogleFonts.playfair(
                          color: Colors.black,
                          fontSize: 25,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  Text("●"),
                  Text(
                    widget.toDisplay.year,
                    style: GoogleFonts.playfair(
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Divider(),
              ArtInfoPanel(artwork: widget.toDisplay),
              //Geosnap(widget.toDisplay),
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
      spacing: 18,
      children: [
        ArtInfoBox(
          iconName: Icons.aspect_ratio,
          text: RenderingServices.dimensions(
            artwork.width.toInt(),
            artwork.height.toInt(),
          ),
        ),
        ArtInfoBox(iconName: Icons.palette, text: artwork.medium),

        Spacer(),
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
      padding: EdgeInsets.all(5),
      child: Card(
        shadowColor: const Color.fromARGB(255, 37, 38, 39),
        elevation: 1.3,

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
