# Flutter Document Scan SDK
A Flutter wrapper for the **Dynamsoft Capture Vision SDK**, featuring document detection and normalization.

![Flutter document scanner for Windows](https://www.dynamsoft.com/codepool/img/2025/05/flutter-document-scanner-windows.png)

![Flutter document scanner normalization for Windows](https://www.dynamsoft.com/codepool/img/2025/05/flutter-document-scanner-normalization-windows.png)
    
## Demo Video
- iOS

  https://github.com/user-attachments/assets/d6f44994-ea37-4f72-8079-6492f52547d2

- Windows

  https://github.com/user-attachments/assets/89113ad1-7699-49a7-ade0-81949cc8ced6

- Web

  https://github.com/user-attachments/assets/3e51915b-c7ad-4406-8ef1-e5cb12fee806

## Supported Platforms
- ✅ Windows
- ✅ Linux
- ✅ Android
- ✅ iOS
    
    - Add camera and microphone usage descriptions to `ios/Runner/Info.plist`:
    
        ```xml
        <key>NSCameraUsageDescription</key>
        <string>Can I use the camera please?</string>
        <key>NSMicrophoneUsageDescription</key>
        <string>Can I use the mic please?</string>
        ```

    - Minimum deployment target: iOS 13.0 or later

- ✅ Web
        
    In `index.html`, include:

    ```html
    <script src="https://cdn.jsdelivr.net/npm/dynamsoft-capture-vision-bundle@2.6.1000/dist/dcv.bundle.min.js"></script>
    ```


## Prerequisites
- A valid [Dynamsoft Capture Vision license key](https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform)

## Getting Started
1. Set the license key in `example/lib/global.dart`:

    ```dart
    Future<int> initDocumentSDK() async {
      int? ret = await docScanner.init(
          "LICENSE-KEY");
      ...
    }
    ```
2. Run the example project on your desired platform:

    ```bash
    cd example
    flutter run -d chrome    # Run on Web
    flutter run -d linux     # Run on Linux
    flutter run -d windows   # Run on Windows
    flutter run              # Run on default connected device (e.g., Android)
    ```

## API Reference

| Method | Description | Parameters | Return Type |
|--------|-------------|------------|-------------|
| `Future<int?> init(String key)` | Initializes the SDK with a license key. | `key`: License string | `Future<int?>` |
| `Future<NormalizedImage?> normalizeFile(String file, List<Offset> points, ColorMode color)` | Normalizes a document image from a file. | `file`: Path to the image file <br> `points`: Document corner points <br> `color`: output image color | `Future<NormalizedImage?>` |
| `Future<NormalizedImage?> normalizeBuffer(Uint8List bytes, int width, int height, int stride, int format, List<Offset> points, int rotation, ColorMode color)` | Normalizes a document image from a raw image buffer. | `bytes`: Image buffer <br> `width`, `height`: Image dimensions <br> `stride`: Row stride in bytes <br> `format`: Image pixel format index <br> `points`: Document corner points <br> `rotation`: 0/90/180/270 <br> `color`: output image color | `Future<NormalizedImage?>` |
| `Future<List<DocumentResult>?> detectFile(String file)` | Detects documents in an image file. | `file`: Path to the image file | `Future<List<DocumentResult>?>` |
| `Future<List<DocumentResult>?> detectBuffer(Uint8List bytes, int width, int height, int stride, int format, int rotation)` | Detects documents from a raw image buffer. | `bytes`: Image buffer <br> `width`, `height`: Image dimensions <br> `stride`: Row stride in bytes <br> `format`: Image pixel format index <br> `rotation`: 0/90/180/270 | `Future<List<DocumentResult>?>` |



