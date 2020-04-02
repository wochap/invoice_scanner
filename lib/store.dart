import 'dart:async';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
// runtimeType
class _ImageState {
  final VisionText imageText;
  final File image;

  _ImageState(this.image, this.imageText);
}

class Store {
  BehaviorSubject _image = BehaviorSubject.seeded(null);
  BehaviorSubject _imageText = BehaviorSubject.seeded(null);

  get imageStream$ => _image.stream;
  get imageTextStream$ => _imageText.stream;
  get image => _image.value;
  get imageText => _imageText.value;
  get stream$ => _image.zipWith(_imageText, (image, imageText) => _ImageState(image, imageText));

  Future selectImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    File croppedImage = await _cropImage(image);
    VisionText visionText = await _readTextFromImage(croppedImage);
    _image.add(croppedImage);
    _imageText.add(visionText);
  }

  Future<File> _cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    );
    return croppedImage;
  }

  Future _readTextFromImage(File croppedImage) async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(croppedImage);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await textRecognizer.processImage(visionImage);
    textRecognizer.close();
    return visionText;
  }
}