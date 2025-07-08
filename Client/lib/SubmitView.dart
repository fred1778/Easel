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

enum ApplicationMed { Oil, Acrylic, Pen, Goucache, Pencil }

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

class SubmitView extends StatelessWidget {
  SubmitView({super.key});
  var title = "";
  var blurb = "";
  var price = 100.0;
  var mediumApp = ApplicationMed.values.first;
  var mediumBase = BaseMed.values.first;
  File? img;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(title: Text("New Artwork")),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            spacing: 18,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ImgPicker(
                setFile: (imageFile) {
                  img = imageFile;
                },
              ),
              EaselInput(
                submit: (str) {
                  title = str;
                },
                placeholder: "What's this piece of art called?",
              ),

              EaselInput(
                submit: (val) {
                  blurb = val;
                },
                placeholder: "Anything you have to say?",
              ),

              SlideSelect(
                change: (val) {
                  price = val;
                },
              ),

              ChipSelector<ApplicationMed>(
                update: (sel) {
                  mediumApp = ApplicationMed.values.firstWhere(
                    (element) => element.name == sel,
                  );
                },
                options: ApplicationMed.values,
              ),
              ChipSelector<BaseMed>(
                update: (sel) {
                  mediumBase = BaseMed.values.firstWhere(
                    (element) => element.name == sel,
                  );
                  print("******************" + mediumBase.name);
                },
                options: BaseMed.values,
              ),

              Spacer(),

              ElevatedButton(
                onPressed: () {
                  //TODO:  really need to tidy up the flow from collection to upload

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
                  );
                  SubmissionManager.addImage(img!, artwork);
                },
                child: Text("Submit Artwork"),
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

  EaselInput({super.key, required this.submit, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: GoogleFonts.playfair(),
      onSubmitted: (String value) {
        submit(value);
      },
      obscureText: false,
      decoration: InputDecoration(
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
          label: Text(widget.options[index].name),
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
    return Slider(
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
    );
  }
}
