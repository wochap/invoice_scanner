import 'package:flutter/material.dart';
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
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: store.stream$,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || (snapshot.data.image == null || snapshot.data.imageText == null)) {
              return Text('No image selected');
            }
            if (snapshot.hasError) {
              return Text(snapshot.error);
            }
            return Column(
              children: <Widget>[
                Image.file(snapshot.data.image),
                Text(snapshot.data.imageText.text)
              ]
            );
          }
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: store.selectImage,
        tooltip: 'Scan',
        child: Icon(Icons.add),
      ),
    );
  }
}