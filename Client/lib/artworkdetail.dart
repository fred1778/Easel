import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homefeed.dart';

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
  void toggleDisplay() {
    setState(() {
      print("toggle text overlay");
      textOverlay = !textOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleDisplay,
      child: Container(
        child: PinchZoom(
          maxScale: 2.5,
          onZoomStart: () {
            print('Start zooming');
          },
          onZoomEnd: () {
            print('Stop zooming');
          },
          child: Stack(
            children: [
              Image(image: AssetImage(widget.toDisplay.imgPath)),
              if (textOverlay)
                ColoredBox(
                  color: Color(0xA9000000),

                  child: Container(
                    padding: EdgeInsets.all(6),

                    child: Column(
                      children: [
                        Text(
                          "Studio Notes",
                          style: GoogleFonts.playfair(
                            color: Color(0x90FFFFFF),
                            fontSize: 40,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          "\"I painted this piece because I wanted to capture an unsuspecting subject. Much of my work has been under the yoke of expensive comissions from men who want to have a record of them or their wives in all their finery. This was something different, something pure.\"",
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
    );
  }
}

class ArtDetailPane extends StatelessWidget {
  final ArtPiece toDisplay;
  const ArtDetailPane({super.key, required this.toDisplay});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ArtWorkFrame(toDisplay: toDisplay),
        Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    toDisplay.title,
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
                  Text(
                    toDisplay.artist,
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
              ArtInfoPanel(artwork: toDisplay),
            ],
          ),
        ),

        Spacer(),
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
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(iconName, color: Colors.blueGrey),
            SizedBox(width: 10),
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
