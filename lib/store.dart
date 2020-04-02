import 'package:rxdart/rxdart.dart';

class Store {
  BehaviorSubject _image = BehaviorSubject.seeded(null);

  get imageStream$ => _image.stream;
  get image => _image.value;

  updateImage(image) { 
    _image.add(image);
  }
}