import 'package:easel/coordinateselector.dart';
import 'package:easel/homefeed.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

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

enum ImgTypes { main, detail, wall, story }

enum BaseMed { Canvas, Paper, Board, Wood, Glass, Photograph }

class MultipleImgPicker extends StatefulWidget {
  ArtSubmissionData artdata;
  MultipleImgPicker({super.key, required this.artdata});

  @override
  State<StatefulWidget> createState() => MultipleImgPickerState();
}

class MultipleImgPickerState extends State<MultipleImgPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color.fromARGB(65, 186, 186, 186)),
      height: 200,
      child: Row(
        children: [
          Spacer(),
          ImgPicker(
            setFile: (selected) {
              widget.artdata.img = selected;
            },
            type: ImgTypes.main,
          ),
          Spacer(),
          ImgPicker(
            setFile: (selected) {
              widget.artdata.imgDtl = selected;
            },
            type: ImgTypes.detail,
          ),

          Spacer(),
        ],
      ),
    );
  }
}

class ImgPicker extends StatefulWidget {
  ImgTypes type;

  final void Function(File) setFile;
  ImgPicker({super.key, required this.setFile, required this.type});
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if (selectedImg != null) Image.file(selectedImg!),
          ElevatedButton(
            onPressed: pickImage,
            child: Text(
              selectedImg == null
                  ? "Select ${widget.type == ImgTypes.main ? "main" : "detail"} image"
                  : "Reselect",
              textAlign: TextAlign.center,
              style: GoogleFonts.playfair(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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
  File? img2;
  var progress = 1;

  var ready = true;

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

              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    if (progress == 2)
                      FilledButton.tonal(
                        onPressed: () {
                          setState(() {
                            progress--;
                            ready = true;
                          });
                        },
                        child: Text(
                          "Back",
                          style: GoogleFonts.playfair(fontSize: 20),
                        ),
                      ),
                    Spacer(),
                    FilledButton(
                      onPressed: (!ready)
                          ? null
                          : () {
                              if (progress == 1) {
                                setState(() {
                                  progress++;
                                  ready = newArt.readyToSubmit();
                                });
                              } else {
                                SubmissionManager.submitArtData(newArt);
                                Navigator.pop(context);
                              }
                            },
                      child: Text(
                        progress == 1 ? "Next" : "Submit",
                        style: GoogleFonts.playfair(fontSize: 20),
                      ),
                    ),
                  ],
                ),
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
  final bool numeric;
  final int? extraHeight;

  EaselInput({
    super.key,
    required this.submit,
    required this.placeholder,
    this.xRestrict,
    this.numeric = false,
    this.extraHeight,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.playfair(),
      onSubmitted: (String value) {
        submit(value);
      },
      onChanged: (value) {
        submit(value);
      },

      obscureText: false,
      maxLines: extraHeight,

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
          child: Row(
            spacing: 5,
            children: [
              Icon(Icons.sell_outlined, color: Colors.blueGrey),

              Text(
                "Select sale price",
                style: GoogleFonts.playfair(fontSize: 24),
              ),
              Spacer(),
              Text(
                "£" + val.toInt().toString(),
                style: GoogleFonts.playfair(fontSize: 24),
              ),
            ],
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

class SubmitSheetB extends StatefulWidget {
  ArtSubmissionData newArt;
  SubmitSheetB({super.key, required this.newArt});
  @override
  State<StatefulWidget> createState() => SubmitSheetBState();
}

class SubmitSheetBState extends State<SubmitSheetB> {
  bool needDepth = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        spacing: 15,
        children: [
          Row(
            children: [
              Text("Where is it?", style: GoogleFonts.playfair(fontSize: 24)),
              Spacer(),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Coordinateselector(artData: widget.newArt),
                    ),
                  );
                },
                child: Text("Select on Map"),
              ),
            ],
          ),

          EaselDivider(),

          Row(
            children: [
              Text(
                "Dimensions (cm)",
                style: GoogleFonts.playfair(fontSize: 24),
              ),
              Spacer(),
            ],
          ),
          Row(
            spacing: 15,
            children: [
              EaselInput(
                submit: ((v) {
                  widget.newArt.artWidth = int.tryParse(v) ?? 0;
                }),
                placeholder: "Width",
                xRestrict: 90,
                numeric: true,
              ),
              Text("x", style: GoogleFonts.playfair(fontSize: 20)),
              EaselInput(
                submit: ((v) {
                  widget.newArt.artLength = int.tryParse(v) ?? 0;
                }),
                placeholder: "Height",
                xRestrict: 90,
                numeric: true,
              ),
              if (needDepth)
                Row(
                  spacing: 15,

                  children: [
                    Text("x", style: GoogleFonts.playfair(fontSize: 20)),
                    EaselInput(
                      submit: ((v) {
                        widget.newArt.artDepth = int.tryParse(v) ?? 0;
                      }),
                      placeholder: "Depth",
                      xRestrict: 90,
                      numeric: true,
                    ),
                  ],
                ),
              Spacer(),
            ],
          ),
          Row(children: [Text("Select Medium"), Spacer()]),
          ChipSelector<ApplicationMed>(
            update: (sel) {
              widget.newArt.mediumApp = ApplicationMed.values.firstWhere(
                (element) => element.name == sel,
              );

              setState(() {
                needDepth =
                    (widget.newArt.mediumApp == ApplicationMed.Ceramics ||
                    widget.newArt.mediumApp == ApplicationMed.Sculpture);
              });
            },
            options: ApplicationMed.values,
          ),
          Row(children: [Text("Select Surface"), Spacer()]),

          ChipSelector<BaseMed>(
            update: (sel) {
              widget.newArt.mediumBase = BaseMed.values.firstWhere(
                (element) => element.name == sel,
              );
            },
            options: BaseMed.values,
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
        spacing: 10,
        children: [
          MultipleImgPicker(artdata: newArt),
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
            extraHeight: 3,
          ),
          EaselDivider(),
          SlideSelect(
            change: (val) {
              newArt.price = val;
            },
          ),

          Spacer(),
          //Divider(),
          Row(children: [Spacer()]),
        ],
      ),
    );
  }
}

class EaselDivider extends StatelessWidget {
  const EaselDivider({super.key});
  @override
  Widget build(BuildContext context) => Divider(
    color: const Color.fromARGB(97, 96, 125, 139),
    indent: 20,
    endIndent: 20,
  );
}
