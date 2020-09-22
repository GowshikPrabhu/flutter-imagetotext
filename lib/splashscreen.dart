import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: null,
      title: Text(
        'Image to Text',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
      ),
      backgroundColor: Colors.black,
    );
  }
}
