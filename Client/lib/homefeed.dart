import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'artworkdetail.dart';

class ArtPiece {
  final String artist;
  final String imgPath;
  final String title;
  final String medium;
  final int width;
  final int height;
  final int price;
  const ArtPiece(
    this.artist,
    this.imgPath,
    this.title,
    this.height,
    this.width,
    this.medium,
    this.price,
  );
}

var artworks = {
  ArtPiece(
    'Johannes Vermeer',
    'images/gwpe.jpg',
    'The Girl with a Pearl Earring',
    100,
    20,
    'Oil on Canvas',
    500,
  ),
  ArtPiece(
    'Mark Rothko',
    'images/rothko.jpg',
    'No.61 (Rust and Blue)',
    50,
    50,
    'Oil on canvas',
    4550,
  ),
  ArtPiece(
    'John Singer Sargent',
    'images/carlillilrose.jpg',
    'Carnation Lily Lily Rose',
    50,
    50,
    'Oil on canvas',
    150000,
  ),
  ArtPiece(
    'Alfred Sisley',
    'images/appleflower.jpg',
    'Apples etc',
    50,
    50,
    'Oil on canvas',
    680000,
  ),
};

class Homefeed extends StatelessWidget {
  const Homefeed({super.key});
  @override
  Widget build(BuildContext context) {
    BootManager.getUserInfo();

    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: artworks.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            final artWork = artworks.elementAt(index);

            print("tap");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtWorkDetail(toDisplay: artWork),
              ),
            );
          },
          child: CardTest(toDisplay: artworks.elementAt(index)),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 25),
    );
  }
}

class CardTest extends StatelessWidget {
  final ArtPiece toDisplay;
  const CardTest({super.key, required this.toDisplay});

  @override
  Widget build(BuildContext context) {
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
                toDisplay.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(toDisplay.medium, style: GoogleFonts.playfairDisplay()),

              Spacer(),
            ],
          ),
          SizedBox(height: 10),
          Image(image: AssetImage(toDisplay.imgPath)),
          SizedBox(height: 10),

          CardPanel(),
        ],
      ),
    );
  }
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
        Icon(
          Icons.add_shopping_cart_sharp,
          color: const Color.fromARGB(183, 14, 93, 109),
          size: 36,
        ),
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
