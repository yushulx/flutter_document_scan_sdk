# Flutter Document Scanner

A Flutter project that demonstrates how to use [Dynamsoft Document Normalizer](https://www.dynamsoft.com/document-normalizer/docs/core/introduction/?ver=latest&ver=latest) to rectify and enhance document images on Android, iOS, Windows, Linux, and web.

https://github.com/user-attachments/assets/45b47b3a-f5c9-40c8-a943-0f28baf9e508

## Online Demo
[https://yushulx.me/flutter_document_scan_sdk/](https://yushulx.me/flutter_document_scan_sdk/)

## Supported Platforms
- **Web**
- **Android**
- **iOS**
- **Windows**
- **Linux** (Without camera support)

## Getting Started
1. Apply for a [30-day trial license](https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform) and replace the license key in the `global.dart` file with your own:

    ```dart
    Future<int> initDocumentSDK() async {
        int? ret = await docScanner.init(
            'LICENSE-KEY');
        if (ret == 0) isLicenseValid = true;
        return ret ?? -1;
    }
    ```

2. Run the project:

    ```
    flutter run
    # flutter run -d windows
    # flutter run -d edge
    # flutter run -d linux
    ```
## Known Issues
The rectified images are converted to base64 strings and saved with [shared_preferences](https://pub.dev/packages/shared_preferences). When the total size of the images you're trying to save exceeds the size limitation of web local storage (typically around 5MB), it can lead to issues such as the app crashing or unexpected behavior.

![web local storage size limitation](https://www.dynamsoft.com/codepool/img/2023/07/flutter-web-local-storage-limitation.png)

## Blog
[How to Build a Cross-platform Document Scanner App with Flutter](https://www.dynamsoft.com/codepool/flutter-document-scanner-app-guide.html)
