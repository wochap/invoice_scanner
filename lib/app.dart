import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoicescanner/main.dart';
import 'package:invoicescanner/store.dart';

class App extends StatelessWidget {
  final store = getIt<Store>();
  final String appTitle;

  App({ @required this.appTitle });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: StreamBuilder(
        stream: store.imageStream$, 
        builder: (BuildContext context, AsyncSnapshot snap) {
          var image = snap.data;
          return image == null ? Text('No image') : Image.file(image);
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scan,
        tooltip: 'Scan',
        child: Icon(Icons.add),
      ),
    );
  }

  Future _scan() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    store.updateImage(image);
  }
}