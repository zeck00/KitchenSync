// ignore_for_file: library_private_types_in_public_api, unused_import, file_names, prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRPage extends StatefulWidget {
  const OCRPage({super.key});

  @override
  _OCRPageState createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  String _recognizedText = "No text recognized yet";
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageAndRecognizeText() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      setState(() {
        _recognizedText = recognizedText.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR Text Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImageAndRecognizeText,
              child: Text('Pick Image and Recognize Text'),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_recognizedText),
            ),
          ],
        ),
      ),
    );
  }
}
