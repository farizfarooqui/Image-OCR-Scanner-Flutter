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
    // Show dialog to choose between camera or gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Check if the image file exists
        if (_selectedImage!.existsSync()) {
          print('Image path: ${image.path}'); // Debug: Check image path

          try {
            await Future.delayed(
                const Duration(seconds: 0)); // Adding delay for camera images
            String text = await performOCR(image.path);
            setState(() {
              ocrText = text;
            });
          } catch (e) {
            print('Error during OCR: $e');
          }
        } else {
          print('Image file not found!');
        }
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
                  ? Container(
                      width: double.infinity,
                      child: Card(
                        shadowColor: Colors.black,
                        borderOnForeground: true,
                        color: Colors.yellow[200],
                        elevation: 8,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                ocrText,
                                style: const TextStyle(fontSize: 16),
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
                        ),
                      ),
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
