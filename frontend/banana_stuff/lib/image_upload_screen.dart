import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({Key? key}) : super(key: key);

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  Uint8List? _imageBytes;
  XFile? _imageFile;
  String _prediction = '';
  double? _confidence;
  bool _predictionVisible = false;
  bool _headerVisible = false;

  final Map<String, String> classNameMapping = {
    "lakatan_ripe_spotted": "Lakatan Ripe Spotted",
    "lakatan_ripe_unspotted": "Lakatan Ripe Unspotted",
    "lakatan_unripe_spotted": "Lakatan Unripe Spotted",
    "lakatan_unripe_unspotted": "Lakatan Unripe Unspotted",
    "latundan_ripe_spotted": "Latundan Ripe Spotted",
    "latundan_ripe_unspotted": "Latundan Ripe Unspotted",
    "latundan_unripe_spotted": "Latundan Unripe Spotted",
    "latundan_unripe_unspotted": "Latundan Unripe Unspotted",
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = imageBytes;
        _prediction = '';
        _confidence = null;
        _predictionVisible = false;
        _headerVisible = false;
      });
    }
  }

  Future<void> _sendImage() async {
    if (_imageFile == null) return;

    var uri = Uri.parse('http://192.168.1.182:8000/predict/');
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

        String rawPrediction = data['class'] ?? 'No prediction received';
        double? confidence = data['confidence']?.toDouble();

        setState(() {
          _headerVisible = true;
          _prediction = classNameMapping[rawPrediction] ?? rawPrediction;
          _confidence = confidence;
          _predictionVisible = true;
        });
      } else {
        setState(() {
          _headerVisible = true;
          _prediction =
              'Failed to get prediction. Status: ${response.statusCode}';
          _predictionVisible = true;
        });
      }
    } catch (e) {
      setState(() {
        _headerVisible = true;
        _prediction = 'Error: $e';
        _predictionVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.black,
              child: const Center(
                child: Text(
                  'BANANA CLASSIFICATION',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.black, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _imageBytes == null
                          ? const Text(
                              'There\'s nothing here cause I don\'t have anything to check',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                              textAlign: TextAlign.center,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.memory(_imageBytes!, height: 200),
                            ),
                      const SizedBox(height: 16),
                      Container(
                        width: isWeb ? 400 : double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _headerVisible
                                ? const Text(
                                    'You\'re giving me work now? Well it\'s-',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 8),
                            if (_predictionVisible) ...[
                              Text(
                                _prediction,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              if (_confidence != null)
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      const TextSpan(
                                          text: 'I am confident that I am '),
                                      TextSpan(
                                        text:
                                            '${_confidence!.toStringAsFixed(2)}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const TextSpan(
                                          text: ' accurate with this one!'),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularButton(Icons.image, _pickImage),
                  _buildCircularButton(Icons.upload, _sendImage),
                  _buildCircularButton(Icons.refresh, _reset),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  void _reset() {
    setState(() {
      _imageBytes = null;
      _imageFile = null;
      _prediction = '';
      _confidence = null;
      _predictionVisible = false;
      _headerVisible = false;
    });
  }
}
