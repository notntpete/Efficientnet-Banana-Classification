import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  Uint8List? _imageBytes;
  XFile? _imageFile;
  String _prediction = '';

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Read the image bytes outside setState
      final imageBytes = await pickedFile.readAsBytes();

      // Update the state with the new values
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = imageBytes;
      });
    }
  }

  // Send image to FastAPI for prediction
  Future<void> _sendImage() async {
    if (_imageFile == null) return;

    var uri = Uri.parse('http://192.168.1.182:8000/predict/');
    // Update with your backend URL

    var request = http.MultipartRequest('POST', uri);

    // Add the image file to the request
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
        // Read the response data
        final responseString = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseString);

        // Get the prediction class from the response
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
      appBar: AppBar(title: Text('Banana Image Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildUI(),
        ),
      ),
    );
  }

  List<Widget> _buildUI() {
    return [
      Center(
        child: _imageBytes == null
            ? Text('No image selected.')
            : Image.memory(_imageBytes!, height: 200),
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: _pickImage,
        child: Text('Pick Image'),
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: _sendImage,
        child: Text('Upload and Predict'),
      ),
      SizedBox(height: 20),
      Text(
        'Prediction: $_prediction',
        style: TextStyle(fontSize: 18),
      ),
    ];
  }
}
