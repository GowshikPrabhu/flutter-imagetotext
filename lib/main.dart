import 'package:flutter/material.dart';
import 'package:imagetotext/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image to Text',
      debugShowCheckedModeBanner: false,
      home: MySplash(),
    );
  }
}
