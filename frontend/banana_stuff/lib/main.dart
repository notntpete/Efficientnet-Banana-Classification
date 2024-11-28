import 'package:flutter/material.dart';
import 'image_upload_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banana Classification',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ImageUploadScreen(),
    );
  }
}
