import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/services.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OcrPageState createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  String ocrText = '';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageAndPerformOCR() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

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

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: ocrText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        title: const Text('Optical Character Recognition'),
        backgroundColor: Colors.amber[300],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: pickImageAndPerformOCR,
                child: const Text('Pick Image and Perform OCR'),
              ),
              const SizedBox(height: 20),
              _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : const Text('No image selected.'),
              const SizedBox(height: 20),
              ocrText.isNotEmpty
                  ? Stack(
                      children: [
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              ocrText,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: copyToClipboard,
                            tooltip: 'Copy Text',
                          ),
                        ),
                      ],
                    )
                  : const Text('No text extracted yet.'),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> performOCR(String imagePath) async {
  String endpoint =
      'https://fariz-ocr.cognitiveservices.azure.com/vision/v3.0/ocr';
  String subscriptionKey = '9fb49c40a3e54f0ebb452deda59767e2';

  // Read the image file as bytes
  var imageBytes = await http.MultipartFile.fromPath('image', imagePath);

  // Convert the file to byte data
  final byteData = imageBytes.finalize();
  final bytes = await byteData.toBytes();

  // Prepare headers
  var headers = {
    'Ocp-Apim-Subscription-Key': subscriptionKey,
    'Content-Type': 'application/octet-stream',
  };

  // Send POST request with image byte data
  var response = await http.post(
    Uri.parse(endpoint),
    headers: headers,
    body: bytes, // Send the raw bytes of the image
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
