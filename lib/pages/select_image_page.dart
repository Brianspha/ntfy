import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/pages/nft_meta_data_page.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/service_locator.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:ntfy/utils/skynet_functions.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as Img;
import 'package:permission_handler/permission_handler.dart';

class SelectImagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SelectImagePageState();
  }
}

class SelectImagePageState extends State<SelectImagePage> {
  File image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height);

    setState(() {
      if (pickedFile != null) {
        var paths = pickedFile.path.split("image_picker_");
        fileName = pickedFile.path;
        imageFile = pickedFile.readAsBytes();
        print("pickedFile: ${paths[paths.length - 1]}");
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Color currentColor = Colors.limeAccent;
  List<Color> currentColors = [Colors.limeAccent, Colors.green];

  SignatureController controller;
  Uint8List data;
  ScreenshotController screenshotController = ScreenshotController();
  var clickedSave = false;
  var isLoading = false;
  String fileName = "";
  var imageFile;

  @override
  void initState() {
    super.initState();
    setState(() {
      controller = SignatureController(
        penStrokeWidth: 1,
        penColor: currentColor,
        exportBackgroundColor: Colors.transparent,
      );
    });
    controller.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    void changeColor(Color color) => setState(() {
          currentColor = color;
          print("changed color");
          controller = SignatureController(
            penStrokeWidth: 1,
            penColor: currentColor,
            exportBackgroundColor: Colors.transparent,
          );
        });
    void changeColors(List<Color> colors) =>
        setState(() => currentColors = colors);
    // TODO: implement build
    return Scaffold(body: ScopedModelDescendant<AppStore>(
        builder: (BuildContext context, Widget child, AppStore model) {
      return SafeArea(
          child: LoadingOverlay(
        child: Hero(
            tag: new Random(10000),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Padding(
                padding: EdgeInsets.only(top: 50, left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        "Mint NFT",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    RawMaterialButton(
                        child: FittedBox(
                          child: Text(
                            "Next",
                            style: TextStyle(
                                color: AppColors.primaryColor, fontSize: 16),
                          ),
                        ),
                        onPressed: image == null && controller.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  this.clickedSave = true;
                                });
                                Permission.storage.request().then((value) => {
                                      if (value.isGranted)
                                        {
                                          screenshotController
                                              .capture()
                                              .then((Uint8List image) async {
                                            var signatureData =
                                                await controller.toPngBytes();
                                            setState(() {
                                              this.isLoading = true;
                                              this.data = image;

                                              model.setSelectedImage(
                                                  image, signatureData);
                                              ImageGallerySaver.saveImage(image)
                                                  .then((results) async => {
                                                        print(
                                                            'set data $results'),
                                                        model
                                                            .setSelectedImagePath(
                                                                this.fileName),
                                                        setState(() {
                                                          this.isLoading =
                                                              false;
                                                          Navigator.push(
                                                              context,
                                                              new MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          new NFTMetaDataPage()));
                                                        })
                                                      });
                                            });
                                          }).catchError((onError) {
                                            print("error: $onError");
                                            this.isLoading = false;
                                          })
                                        }
                                      else
                                        {print("Permissions not granted")}
                                    });
                                /**/
                              })
                  ],
                ),
              ),
              Expanded(
                  child: Screenshot(
                      controller: screenshotController,
                      child: Center(
                        child: Stack(
                            alignment: FractionalOffset.center,
                            children: [
                              Center(
                                child: image == null
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Card(
                                            child: InkWell(
                                          onTap: getImage,
                                          child: Center(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Select',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color:
                                                        AppColors.primaryColor),
                                              ),
                                              Icon(
                                                Icons.add,
                                                color: AppColors.primaryColor,
                                                size: 30,
                                              ),
                                              Text(
                                                'Image',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color:
                                                        AppColors.primaryColor),
                                              )
                                            ],
                                          )),
                                        )))
                                    : Image.file(
                                        image,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                      ),
                              ),
                              if (image != null)
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Signature(
                                    controller: controller,
                                    height: MediaQuery.of(context).size.height,
                                    backgroundColor: Colors.transparent,
                                  ),
                                )
                            ]),
                      ))),
              if (image != null)
                Center(
                  widthFactor: 100,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Colors.white)))),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  content: SingleChildScrollView(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .55,
                                      child: Column(
                                        children: [
                                          ColorPicker(
                                            pickerColor: currentColor,
                                            onColorChanged: (Color value) {
                                              changeColor(value);
                                            },
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              child: FittedBox(
                                                child: Text(
                                                  "Close",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        child: FittedBox(
                          child: Text(
                            "Change Color",
                            style: TextStyle(
                                color: AppColors.black, fontSize: 15),
                          ),
                        )),
                  ),
                )
            ])),
        isLoading: isLoading,
      ));
    }));
  }
}
