import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CustomLayoutScreen extends StatefulWidget {
  @override
  _CustomLayoutScreenState createState() => _CustomLayoutScreenState();
}

class _CustomLayoutScreenState extends State<CustomLayoutScreen> {
  Uint8List? _imageBytes;
  XFile? _imageFile;
  String _prediction = '';

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = imageBytes;
      });
    }
  }

  // Send image to FastAPI for prediction
  Future<void> _sendImage() async {
    if (_imageFile == null) return;

    var uri = Uri.parse(
        'http://192.168.1.182:8000/predict/'); // Update with your backend URL
    var request = http.MultipartRequest('POST', uri);

    var imageFile = http.MultipartFile.fromBytes(
      'file',
      _imageBytes!,
      filename: _imageFile!.name,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(imageFile);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseString);

        setState(() {
          _prediction = data['class'] ?? 'No prediction received';
        });
      } else {
        setState(() {
          _prediction =
              'Failed to get prediction. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue, // Blue background
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.black, // Header background color
              child: Center(
                child: Text(
                  'BANANA CLASSIFICATION',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Orange rectangle with content
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.orange, // Orange rectangle background
                    borderRadius:
                        BorderRadius.circular(16.0), // Rounded corners
                    border: Border.all(
                        color: Colors.black, width: 2.0), // Black border
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _imageBytes == null
                          ? Text('No image selected.')
                          : Image.memory(_imageBytes!, height: 200),
                      SizedBox(height: 16),
                      Text(
                        'Prediction:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _prediction,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Row for circular buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularButton(
                      Icons.image, _pickImage), // Pick Image button
                  _buildCircularButton(
                      Icons.upload, _sendImage), // Upload and Predict button
                  _buildCircularButton(Icons.refresh, _reset), // Reset button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create circular buttons
  Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white, // Button background color
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2.0), // Black border
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  // Reset the image and prediction
  void _reset() {
    setState(() {
      _imageBytes = null;
      _imageFile = null;
      _prediction = '';
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: CustomLayoutScreen(),
  ));
}
