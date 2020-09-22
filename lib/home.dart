import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  File _image;
  final _picker = ImagePicker();
  String resultText = 'Fetching...';

  pickImage() async {
    var image = await _picker.getImage(source: ImageSource.camera);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      _loading = false;
    });

    var str = fetchResponse(_image);
    print(str);
  }

  pickFromGallery() async {
    var image = await _picker.getImage(source: ImageSource.gallery);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      _loading = false;
    });

    var str = fetchResponse(_image);
    print(str);
  }

  Future<Map<String, dynamic>> fetchResponse(File image) async {
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    final baseUrl =
        'http://max-image-caption-generator-gowshik-test.2886795276-80-kota05.environments.katacoda.com/model/predict';
    final imageUploadRequest =
        http.MultipartRequest('POST', Uri.parse(baseUrl));

    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> responseData = json.decode(response.body);
      parseResponse(responseData);
      return responseData;
    } catch (e) {
      print('Error: ' + e);
      return null;
    }
  }

  void parseResponse(var response) {
    String r = '';
    var predictions = response['predictions'];

    for (var prediction in predictions) {
      var caption = prediction['caption'];
      var probability = prediction['probability'];
      r = r + '$caption\n\n';
    }

    setState(() {
      resultText = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.005, 1],
            colors: [Color(0xFF3C3B3F), Color(0xFF605C3C)],
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),
              Text(
                'Image to Text',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Container(
                  height: MediaQuery.of(context).size.height - 150,
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: _loading
                            ? Container(
                                width: 500,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: 100,
                                      child: Image.asset('assets/bgimg.png'),
                                    ),
                                    SizedBox(height: 30),
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          150,
                                      child: Column(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: pickImage,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 15,
                                              ),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.deepPurple[300],
                                              ),
                                              child: Text(
                                                'Take a photo',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          GestureDetector(
                                            onTap: pickFromGallery,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 15,
                                              ),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.deepPurple[300],
                                              ),
                                              child: Text(
                                                'Pick a photo',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 15,
                                              ),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.deepPurple[300],
                                              ),
                                              child: Text(
                                                'Live camera',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        height: 200,
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _loading = true;
                                                      resultText =
                                                          'Fetching...';
                                                    });
                                                  },
                                                  icon: Icon(
                                                      Icons.arrow_back_ios),
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    200,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.file(
                                                    _image,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                            ])),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      child: Text(
                                        '$resultText',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
