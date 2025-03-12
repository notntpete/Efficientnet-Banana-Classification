import 'package:flutter/material.dart';
import 'image_upload_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banana Classification',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: IntroScreen(),
    );
  }
}

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //change color
        color: Colors.blue, // Blue background
        child: Center(
          child: GestureDetector(
            onTap: () {
              // Navigate to the Image Upload Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageUploadScreen()),
              );
            },
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.orange, // Button background color
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.black, width: 4), // Black border
              ),
              child: Center(
                child: Text(
                  'GO',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
