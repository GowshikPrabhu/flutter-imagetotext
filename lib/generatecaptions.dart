import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class GenerateCaptions extends StatefulWidget {
  @override
  _GenerateCaptionsState createState() => _GenerateCaptionsState();
}

class _GenerateCaptionsState extends State<GenerateCaptions> {
  String resultText = 'Fetching...';
  List<CameraDescription> cameras;
  CameraController controller;
  bool takePhoto = false;

  @override
  void initState() {
    super.initState();
    takePhoto = true;

    detectCameras().then((_) {
      initializeController();
    });
  }

  Future<void> detectCameras() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void initializeController() {
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if(!mounted) {
        return;
      }
      if(takePhoto) {
        const interval = const Duration(seconds: 3);
        new Timer.periodic(interval, (Timer t) => capturePictures());
      }
    });
  }

  capturePictures() async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/{$timestamp}.png';

    if(takePhoto) {
      controller.takePicture(filePath).then((_) {
        if(takePhoto) {
          File imgFile = File(filePath);
          fetchResponse(imgFile);
        } else {
          return;
        }
      });
    }
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
    return Container();
  }
}
