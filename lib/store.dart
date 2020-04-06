import 'dart:async';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class _ImageState {
  final VisionText imageText;
  final Size imageSize;
  final File image;

  _ImageState(this.image, this.imageSize, this.imageText);
}

class Store {
  BehaviorSubject _image = BehaviorSubject.seeded(null);
  BehaviorSubject _imageSize = BehaviorSubject.seeded(null);
  BehaviorSubject _imageText = BehaviorSubject.seeded(null);

  get imageStream$ => _image.stream;
  get imageSizeStream$ => _imageSize.stream;
  get imageTextStream$ => _imageText.stream;
  get image => _image.value;
  get imagesize => _imageSize.value;
  get imageText => _imageText.value;
  get stream$ => Rx.combineLatest3(
        _image,
        _imageSize,
        _imageText,
        (image, imageSize, imageText) =>
            _ImageState(image, imageSize, imageText),
      );

  Future selectImage(ImageSource source) async {
    final File image = await ImagePicker.pickImage(source: source);
    if (image == null) {
      return;
    }
    File croppedImage = await _cropImage(image);
    if (croppedImage == null) {
      croppedImage = image;
    }
    final VisionText visionText = await _readTextFromImage(croppedImage);
    final Size imageSize = await _getImageSize(croppedImage);
    _image.add(croppedImage);
    _imageSize.add(imageSize);
    _imageText.add(visionText);
  }

  Future<Size> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    return imageSize;
  }

  Future<File> _cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.purple,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: false,
        hideBottomControls: true,
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );
    return croppedImage;
  }

  Future _readTextFromImage(File croppedImage) async {
    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(croppedImage);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await textRecognizer.processImage(visionImage);
    textRecognizer.close();
    return visionText;
  }
}
