import 'package:easel/FavouritesList.dart';
import 'package:easel/SubmitView.dart';
import 'package:easel/coordinateselector.dart';
import 'package:easel/genericlist.dart';
import 'package:easel/homefeed.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'submissionmanager.dart';
import 'userhome.dart';

const agreement =
    "Easel is a market place for human artists to sell their work. We think this is especially important today with the rise of generative AI. When you post artwork to Easel, we use an image moderation service to check your submission is not AI-generated. In some cases, submissions are manually reviewed by other users.";

enum subjects { Landscape, Portraits, Wildlife, Still_Life, Abstract }

enum medias {
  Painting,
  Drawing,
  Pen,
  Collage,
  Multimedia,
  Digital,
  Ceramic,
  Sclupture,
}

class ProfileEnrich extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> selectedSubjects = [];
    List<String> selectedMedia = [];
    List<num> location = [];
    String aboutMe = "";

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit your artist profile"),
        titleTextStyle: GoogleFonts.playfair(color: Colors.black, fontSize: 20),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(10),
        /* child:
           Container(
            padding: EdgeInsets.all(6),
            child: Column(
              spacing: 10,*/
        children: [
          Row(
            children: [
              Text(
                "Welcome, " + BootManager.currentUserProfile!.name,
                style: GoogleFonts.playfair(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 20),

          Row(
            // extract into reusable widget
            children: [
              Text(
                "Introduce yourself...",
                style: GoogleFonts.playfair(fontSize: 25),
              ),
              Spacer(),
            ],
          ),
          TextField(
            textInputAction: TextInputAction.done,
            onSubmitted: (v) {
              print("dd");
              aboutMe = v;
            },
            minLines: 3,
            maxLines: 7,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onChanged: (v) {
              aboutMe = v;
            },
          ),

          SizedBox(height: 28),
          Row(
            children: [
              Text(
                "My subjects are mainly...",
                style: GoogleFonts.playfair(fontSize: 25),
              ),
              Spacer(),
            ],
          ),

          MultiChipSelector(
            update: (item) {
              selectedSubjects.add(item);
            },
            options: subjects.values,
          ),
          SizedBox(height: 28),

          Row(
            children: [
              Text(
                "I like to make art using...",
                style: GoogleFonts.playfair(fontSize: 25),
              ),
              Spacer(),
            ],
          ),

          MultiChipSelector(
            update: (item) {
              // need to remove item as well?
              selectedMedia.add(item);
            },
            options: medias.values,
          ),
          SizedBox(height: 28),
          Row(
            children: [
              Text(
                "Where are you based?",
                style: GoogleFonts.playfair(fontSize: 25),
              ),
              Spacer(),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: Text(
                  "This helps us connect you to local buyers. Other users will only know that you are based within a 10 km radius",
                  style: GoogleFonts.playfair(fontSize: 15),
                ),
              ),
              //   Spacer(),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Coordinateselector(
                        currentUserLocaleMode: true,
                        onLocationSelected: (point) {
                          location = [
                            point.coordinates.lat,
                            point.coordinates.lng,
                          ];
                        },
                      ),
                    ),
                  );
                },
                child: Text("Select locale >"),
              ),
            ],
          ),
          SizedBox(height: 28),

          AgreementBox(),
          Spacer(),
          SizedBox(height: 100),
          FilledButton(
            onPressed: () {
              BootManager.upgradeToArtist(
                aboutMe,
                location,
                selectedSubjects,
                selectedMedia,
              );
              Navigator.pop(context);
              BootManager.getUserInfo();
            },
            child: Row(
              children: [
                Spacer(),
                Text(
                  "Submit",
                  style: GoogleFonts.playfair(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );

    //),
    //);
  }
}

class MultiChipSelector<T extends Enum> extends StatefulWidget {
  const MultiChipSelector({
    super.key,
    required this.update,
    required this.options,
  });
  final void Function(String) update;
  final List<T> options;

  @override
  State<StatefulWidget> createState() => MultiChipSelectState<T>();
}

class MultiChipSelectState<T extends Enum> extends State<MultiChipSelector> {
  List<int> selected = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: List.generate(widget.options.length, (index) {
        return FilterChip(
          label: Text(
            RenderingServices.underscoreToSpace(widget.options[index].name),
          ), // use a method on name to get formatted eg _ -> space
          selected: selected.contains(index),
          onSelected: (bool val) {
            widget.update(widget.options[index].name);
            setState(() {
              if (val) {
                selected.add(index);
              } else {
                selected.remove(index);
              }
            });
          },
        );
      }),
    );
  }
}

// stateful widget for T&cs

class AgreementBox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AgreementBoxState();
}

class AgreementBoxState extends State<AgreementBox> {
  var check = false;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(149, 88, 111, 122)),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          spacing: 10,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,

                  size: 30,
                  color: const Color.fromRGBO(210, 122, 45, 1),
                ),
                Text(
                  "Keeping Easel human",
                  style: GoogleFonts.playfair(
                    fontSize: 26,
                    color: const Color.fromRGBO(210, 122, 45, 1),
                  ),
                ),
              ],
            ),
            Text(agreement, style: GoogleFonts.playfair(fontSize: 20)),
            Row(
              children: [
                Spacer(),
                Text("I agree", style: GoogleFonts.playfair(fontSize: 16)),
                Checkbox(
                  value: check,
                  onChanged: (val) {
                    setState(() {
                      check = val!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
