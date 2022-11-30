# flutter_document_scan_sdk
The Flutter plugin is a wrapper for Dynamsoft's [Document Normalizer SDK](https://www.dynamsoft.com/document-normalizer/docs/introduction/). It allows you to do document edge detection and normalization.

## Getting a License Key for Dynamsoft Document Normalizer
[![](https://img.shields.io/badge/Get-30--day%20FREE%20Trial-blue)](https://www.dynamsoft.com/customer/license/trialLicense/?product=ddn)

## Supported Platforms
- Web

## Installation
1. Add `flutter_document_scan_sdk` as a dependency in your `pubspec.yaml` file.

    ```yml
    dependencies:
        ...
        flutter_document_scan_sdk:
    ```
2. Include the JavaScript library of Dynamsoft Document Normalizer in your `index.html` file:

    ```html
    <script src="https://cdn.jsdelivr.net/npm/dynamsoft-document-normalizer@1.0.11/dist/ddn.js"></script>
    ```


## Usage
- Initialize the document normalizer SDK with resource path and license key:

     ```dart
    final _flutterDocumentScanSdkPlugin = FlutterDocumentScanSdk();
    await _flutterDocumentScanSdkPlugin.init(
        "https://cdn.jsdelivr.net/npm/dynamsoft-document-normalizer@1.0.11/dist/",
        "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");

    await _flutterDocumentScanSdkPlugin.setParameters(Template.grayscale);
    ```

- Do document edge detection and return quadrilaterals:

    ```dart
    List<DocumentResult> detectionResults =
            await _flutterDocumentScanSdkPlugin
                .detect(file);
    ```
- Normalize the document based on four corner coordinates:

    ```dart
    NormalizedImage? normalizedImage = await _flutterDocumentScanSdkPlugin.normalize(
        file, detectionResults[0].points);
    ```

- Save the document to the local disk:

    ```dart
    await _flutterDocumentScanSdkPlugin
                                .save('normalized.png');
    ```

## Try the Example

```bash
cd example
flutter run -d chrome
```

![Flutter web document edge detection and normalization](https://www.dynamsoft.com/codepool/img/2022/11/flutter-document-edge-detection-normalization.png)

