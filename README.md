## Optical Character Recognition (OCR) App

This Flutter app allows users to perform Optical Character Recognition (OCR) on images selected from the camera or gallery. The app extracts text from the image using Azure Cognitive Services' OCR API.

### Features:
- **Image Picker:** Users can choose to upload an image either from the camera or gallery.
- **OCR Functionality:** The app sends the selected image to an Azure OCR API to extract the text.
- **Text Display:** Extracted text is displayed on the screen.
- **Copy to Clipboard:** Users can easily copy the extracted text by tapping a button.

### Technologies Used:
- **Flutter & Dart:** For building the UI and app logic.
- **Azure OCR API:** For performing optical character recognition.
- **Image Picker:** To choose images from the device’s camera or gallery.
- **HTTP Package:** For making API requests.
- **Clipboard Service:** For copying extracted text to the clipboard.

### Setup Instructions:
1. Clone the repository and navigate to the project directory.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Replace the placeholder `subscriptionKey` in the `performOCR` function with your Azure OCR API key.
4. Run the app:
   ```bash
   flutter run
   ```

### API Usage:
- Azure OCR API (`v3.0`) is used to process the images and extract text. Make sure to create a Cognitive Services resource on Azure to get your API key.

### Dependencies:
- `flutter/material.dart`
- `image_picker`
- `http`
- `dart:io`
- `flutter/services.dart`

This app demonstrates how to integrate Azure OCR services with a Flutter app to extract text from images.

## Connect with Me
Feel free to reach out if you have any questions, suggestions, or just want to say hi!

LinkedIn: https://www.linkedin.com/in/fariz-farooqui-97b48026b/.

Instagram: farizfarooqui104
