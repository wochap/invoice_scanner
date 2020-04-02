import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:invoicescanner/app.dart';
import 'package:invoicescanner/store.dart';

final getIt = GetIt.instance;
String appTitle = 'Invoice Scanner';

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: App(appTitle: appTitle),
    );
  }
}

void setup() {
  GetIt.I.registerSingleton<Store>(Store());
}

void main() {
  setup();
  runApp(Root());
}