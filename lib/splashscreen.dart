import 'package:flutter/material.dart';
import 'package:imagetotext/home.dart';
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
      navigateAfterSeconds: HomeScreen(),
      title: Text(
        'Image to Text',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
      ),
      image: Image.asset('assets/bgimg.png'),
      backgroundColor: Colors.black,
      loaderColor: Colors.lightBlue[700],
      loadingText: Text(
        'Loading...',
        style: TextStyle(color: Colors.white),
      ),
      photoSize: 100,
    );
  }
}
