import 'package:easel/coordinateselector.dart';
import 'package:easel/homefeed.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'submissionmanager.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum ApplicationMed {
  Oil,
  Acrylic,
  Pen,
  Goucache,
  Pencil,
  Sculpture,
  Ceramics,
  Print,
}

enum BaseMed { Canvas, Paper, Board, Wood, Glass, Photograph }

class ImgPicker extends StatefulWidget {
  final void Function(File) setFile;
  ImgPicker({super.key, required this.setFile});
  @override
  State<StatefulWidget> createState() => ImgPickerState();
}

class ImgPickerState extends State<ImgPicker> {
  ImagePicker imgPicker = ImagePicker();
  File? selectedImg;
  int step = 1;

  Future<void> pickImage() async {
    final selected = await imgPicker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImg = File(selected!.path);
      print(selected.path);
      if (selectedImg != null) {
        widget.setFile(selectedImg!);
      }

      //SubmissionManager.addImage(selectedImg!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0x10000000),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (selectedImg != null)
            Container(width: 100, height: 100, child: Image.file(selectedImg!)),
          if (selectedImg == null)
            ElevatedButton(
              onPressed: pickImage,
              child: Text(selectedImg == null ? "Select Image" : "Reselect"),
            ),
        ],
      ),
    );
  }
}

class SubmitView extends StatefulWidget {
  SubmitView({super.key});

  @override
  State<StatefulWidget> createState() => SubmitViewState();
}

class SubmitViewState extends State<SubmitView> {
  var title = "";
  var blurb = "";
  var price = 100.0;
  var mediumApp = ApplicationMed.values.first;
  var mediumBase = BaseMed.values.first;
  File? img;
  var progress = 1;

  ArtSubmissionData newArt = ArtSubmissionData();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(title: Text("New Artwork", style: GoogleFonts.playfair())),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            spacing: 10,
            children: [
              LinearProgressIndicator(value: progress / 2),
              if (progress == 1)
                Expanded(child: SubmitSheetA(newArt: newArt))
              else
                Expanded(child: SubmitSheetB(newArt: newArt)),

              Row(
                children: [
                  if (progress == 2)
                    FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          progress--;
                        });
                      },
                      child: Text("Back"),
                    ),
                  Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (progress == 1) {
                        setState(() {
                          progress++;
                        });
                      } else {}
                    },
                    child: Text(progress == 1 ? "Next" : "Submit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EaselInput extends StatelessWidget {
  final void Function(String) submit;
  final String placeholder;
  final double? xRestrict;

  EaselInput({
    super.key,
    required this.submit,
    required this.placeholder,
    this.xRestrict,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: GoogleFonts.playfair(),
      onSubmitted: (String value) {
        submit(value);
      },

      obscureText: false,

      decoration: InputDecoration(
        constraints: (xRestrict != null)
            ? BoxConstraints(maxWidth: xRestrict!)
            : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        labelText: placeholder,
        labelStyle: GoogleFonts.playfair(),
      ),
    );
  }
}

class SlideSelect extends StatefulWidget {
  final void Function(double) change;

  SlideSelect({super.key, required this.change});
  @override
  State<StatefulWidget> createState() => SlideState();
}

class ChipSelector<T extends Enum> extends StatefulWidget {
  const ChipSelector({super.key, required this.update, required this.options});
  final void Function(String) update;
  final List<T> options;

  @override
  State<StatefulWidget> createState() => ChipSelectState<T>();
}

class ChipSelectState<T extends Enum> extends State<ChipSelector> {
  int? selected = 0;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: List.generate(widget.options.length, (index) {
        return ChoiceChip(
          label: Text(
            RenderingServices.underscoreToSpace(widget.options[index].name),
          ),
          selected: selected == index,
          onSelected: (bool val) {
            widget.update(widget.options[index].name);
            setState(() {
              selected = val ? index : null;
            });
          },
        );
      }),
    );
  }
}

class SlideState extends State<SlideSelect> {
  @override
  double val = 5.0;
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          child: Text(
            "Price £" + val.toInt().toString(),
            style: GoogleFonts.playfair(fontSize: 20),
          ),
        ),
        Slider(
          activeColor: Colors.blueGrey,
          label: "£" + val.toInt().toString(),
          divisions: 99,
          value: val,
          min: 5,
          max: 500,
          onChanged: (value) {
            setState(() {
              val = value;
              widget.change(val);
            });
          },
        ),
      ],
    );
  }
}

class SubmitSheetB extends StatelessWidget {
  ArtSubmissionData newArt;
  SubmitSheetB({super.key, required this.newArt});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        spacing: 15,
        children: [
          Row(
            children: [
              Text("Where is it?"),
              Spacer(),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Coordinateselector(artData: newArt),
                    ),
                  );
                },
                child: Text("Select on Map"),
              ),
            ],
          ),

          Row(children: [Text("Dimensions"), Spacer()]),
          Row(
            spacing: 15,
            children: [
              EaselInput(
                submit: ((v) {
                  print(v);
                }),
                placeholder: "Width",
                xRestrict: 100,
              ),
              EaselInput(
                submit: ((v) {
                  print(v);
                }),
                placeholder: "Height",
                xRestrict: 120,
              ),
              if (newArt.mediumApp == ApplicationMed.Ceramics ||
                  newArt.mediumApp == ApplicationMed.Sculpture)
                EaselInput(
                  submit: ((v) {
                    print(v);
                  }),
                  placeholder: "Depth",
                  xRestrict: 120,
                ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class SubmitSheetA extends StatelessWidget {
  ArtSubmissionData newArt;
  SubmitSheetA({required this.newArt});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ImgPicker(
            setFile: (imageFile) {
              newArt.img = imageFile;
            },
          ),
          EaselInput(
            submit: (str) {
              newArt.title = str;
            },
            placeholder: "What's this piece of art called?",
          ),

          EaselInput(
            submit: (val) {
              newArt.blurb = val;
            },
            placeholder: "Why did you make it?",
          ),

          SlideSelect(
            change: (val) {
              newArt.price = val;
            },
          ),

          ChipSelector<ApplicationMed>(
            update: (sel) {
              newArt.mediumApp = ApplicationMed.values.firstWhere(
                (element) => element.name == sel,
              );
            },
            options: ApplicationMed.values,
          ),
          ChipSelector<BaseMed>(
            update: (sel) {
              newArt.mediumBase = BaseMed.values.firstWhere(
                (element) => element.name == sel,
              );
            },
            options: BaseMed.values,
          ),

          Spacer(),
          Divider(),
          Row(children: [Spacer()]),
        ],
      ),
    );
  }
}





 /*  FilledButton(
                    onPressed: () {
                      var med = "${mediumApp.name} on ${mediumBase.name}";
                      var int_price = price.toInt();
                      var artwork = ArtPiece(
                        "/",
                        "/",
                        title,
                        40,
                        40,
                        med,
                        int_price,
                        blurb,
                        [55.0393, -1.39, 0.0],
                        "2025",
                      );
                      SubmissionManager.addImage(img!, artwork);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: Text(
                      "Submit Artwork",
                      style: GoogleFonts.playfair(fontSize: 20),
                    ),
                  ),*/