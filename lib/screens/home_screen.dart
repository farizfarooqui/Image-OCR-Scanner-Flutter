import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class OcrPage extends StatefulWidget {
  @override
  _OcrPageState createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  String ocrText = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageAndPerformOCR() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        String text = await performOCR(image.path);
        setState(() {
          ocrText = text;
        });
      } catch (e) {
        print('Error during OCR: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR Example'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickImageAndPerformOCR,
            child: Text('Pick Image and Perform OCR'),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(ocrText),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> performOCR(String imagePath) async {
  // Azure OCR endpoint
  String endpoint = 'https://<your-computer-vision-endpoint>/vision/v3.2/ocr';
  String subscriptionKey = '<your-subscription-key>';

  // Read the image file
  var imageBytes = await http.MultipartFile.fromPath('image', imagePath);

  // Prepare headers and body
  var headers = {
    'Ocp-Apim-Subscription-Key': subscriptionKey,
    'Content-Type': 'application/octet-stream',
  };

  // Send POST request with image data
  var response = await http.post(
    Uri.parse(endpoint),
    headers: headers,
    body: imageBytes.finalize(), // Finalize prepares it for upload
  );

  // Check response status
  if (response.statusCode == 200) {
    var result = jsonDecode(response.body);
    return extractTextFromResult(result);
  } else {
    throw Exception('Failed to perform OCR: ${response.body}');
  }
}

// Function to extract text from the Azure OCR result
String extractTextFromResult(Map<String, dynamic> result) {
  String extractedText = '';

  if (result.containsKey("regions")) {
    for (var region in result["regions"]) {
      for (var line in region["lines"]) {
        extractedText +=
            line["words"].map((word) => word["text"]).join(' ') + '\n';
      }
    }
  }

  return extractedText;
}
