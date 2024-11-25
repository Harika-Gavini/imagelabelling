import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageLabelingScreen extends StatefulWidget {
  @override
  _ImageLabelingScreenState createState() => _ImageLabelingScreenState();
}

class _ImageLabelingScreenState extends State<ImageLabelingScreen> {
  List<String> _labels = [];
  List<String> _assetImages = [
    'assets/women.jpeg',
    'assets/study.jpeg',
    'assets/giraffee.jpeg',
    'assets/icecreamsundae.jpeg',
    'assets/chocolatecake.jpeg',
  ]; // List of your asset image paths

  // Load an image from assets and process it
  Future<void> _labelAssetImage(String assetPath) async {
    try {
      // Load asset as a byte array
      final ByteData byteData = await rootBundle.load(assetPath);
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/temp.jpg');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // Perform image labeling
      await _labelImage(tempFile);
    } catch (e) {
      print('Error loading or processing asset image: $e');
    }
  }

  // Label the image using Firebase ML Kit
  Future<void> _labelImage(File image) async {
    try {
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFile(image);
      final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
      final List<ImageLabel> labels = await labeler.processImage(visionImage);

      setState(() {
        _labels = labels
            .map((label) =>
                '${label.text} (${label.confidence?.toStringAsFixed(2) ?? 'N/A'})')
            .toList();
      });

      // Close the labeler to release resources
      labeler.close();
    } catch (e) {
      print('Error processing image for labels: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeling with ML Kit'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _assetImages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Image ${index + 1}'),
                  leading:
                      Image.asset(_assetImages[index], width: 50, height: 50),
                  onTap: () => _labelAssetImage(_assetImages[index]),
                );
              },
            ),
          ),
          if (_labels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _labels.map((label) => Text(label)).toList(),
              ),
            ),
          if (_labels.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No labels detected yet. Select an image from the list above.',
                style: TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
