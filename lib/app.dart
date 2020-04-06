import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoicescanner/main.dart';
import 'package:invoicescanner/store.dart';
import 'package:invoicescanner/utils.dart';

class App extends StatelessWidget {
  final store = getIt<Store>();
  final String appTitle;

  App({@required this.appTitle});

  _buildResults(File image, Size imageSize, VisionText visionText) {
    final CustomPainter painter = TextDetectorPainter(imageSize, visionText);
    return CustomPaint(
      painter: painter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(appTitle)),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: store.stream$,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData ||
                (snapshot.data.image == null ||
                    snapshot.data.imageText == null ||
                    snapshot.data.imageSize == null)) {
              return Text('No image selected');
            }
            if (snapshot.hasError) {
              return Text(snapshot.error);
            }
            return Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Image.file(snapshot.data.image),
                    Positioned(
                      child: _buildResults(snapshot.data.image,
                          snapshot.data.imageSize, snapshot.data.imageText),
                      bottom: 0,
                      right: 0,
                      top: 0,
                      left: 0,
                    ),
                  ],
                ),
                Text(snapshot.data.imageText.text),
              ],
            );
          },
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: <SpeedDialChild>[
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
            onTap: () => store.selectImage(ImageSource.camera),
          ),
          SpeedDialChild(
            child: Icon(Icons.perm_media),
            onTap: () => store.selectImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
