import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'image_labeling_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Labeling App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageLabelingScreen(),
    );
  }
}
