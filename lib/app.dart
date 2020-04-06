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

  Widget _buildOCRResults(File image, Size imageSize, VisionText visionText) {
    final CustomPainter painter = TextDetectorPainter(imageSize, visionText);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Icon(
            Icons.broken_image,
            size: 160,
            color: Colors.black54,
          ),
          Text(
            'Select an image',
            style: Theme.of(context).textTheme.display1,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AsyncSnapshot snapshot) {
    if (!snapshot.hasData ||
        (snapshot.data.image == null ||
            snapshot.data.imageText == null ||
            snapshot.data.imageSize == null)) {
      return _buildEmptyState(context);
    }
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Image.file(snapshot.data.image),
            Positioned(
              child: _buildOCRResults(snapshot.data.image,
                  snapshot.data.imageSize, snapshot.data.imageText),
              bottom: 0,
              right: 0,
              top: 0,
              left: 0,
            ),
          ],
        ),
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            snapshot.data.imageText.text,
            textDirection: TextDirection.ltr,
          ),
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 80),
        ),
      ],
    );
  }

  Widget _buildScrollContainer(
    BuildContext context,
    BoxConstraints viewportConstraints,
  ) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: viewportConstraints.maxHeight - kToolbarHeight,
        ),
        child: StreamBuilder(
          stream: store.stream$,
          builder: _buildContent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(appTitle)),
      ),
      body: LayoutBuilder(
        builder: _buildScrollContainer,
      ),
      floatingActionButton: SpeedDial(
        overlayColor: Colors.black,
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
