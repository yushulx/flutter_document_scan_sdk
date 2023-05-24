# flutter_document_scan_sdk
The Flutter plugin is a wrapper for Dynamsoft's [Document Normalizer SDK](https://www.dynamsoft.com/document-normalizer/docs/introduction/). It enables you to build document rectification applications for **Windows**, **Linux**, **web**, **Android** and **iOS**.

## Try Document Rectification Example

### Desktop: Windows & Linux


**Windows** 

```bash
cd example
flutter run -d windows
```

![Flutter windows document edge detection and normalization](https://www.dynamsoft.com/codepool/img/2022/12/flutter-windows-desktop-document-scanner.png)


**Linux**

```bash
cd example
flutter run -d linux
```

![Flutter Linux document edge detection and normalization](https://www.dynamsoft.com/codepool/img/2022/12/flutter-linux-desktop-document-scanner.png)

### Web
```bash
cd example
flutter run -d chrome
```

![Flutter web document edge detection and normalization](https://www.dynamsoft.com/codepool/img/2023/05/document-edge-edit.png)

### Mobile: Android & iOS

```bash
cd example
flutter run 
```

![Flutter document rectification for Android and iOS](https://www.dynamsoft.com/codepool/img/2023/02/flutter-document-rectification-android-ios.jpg)

## Getting a License Key for Dynamsoft Document Normalizer
[![](https://img.shields.io/badge/Get-30--day%20FREE%20Trial-blue)](https://www.dynamsoft.com/customer/license/trialLicense/?product=ddn)

## Supported Platforms
- Web
- Windows
- Linux
- Android
- iOS

## Installation
Add `flutter_document_scan_sdk` as a dependency in your `pubspec.yaml` file.

```yml
dependencies:
    ...
    flutter_document_scan_sdk:
```

### One More Step for Web
Include the JavaScript library of Dynamsoft Document Normalizer in your `index.html` file:

```html
<script src="https://cdn.jsdelivr.net/npm/dynamsoft-document-normalizer@1.0.12/dist/ddn.js"></script>
```

## API Compatibility
| Methods      | Android |    iOS | Windows | Linux | macOS | Web|
| ----------- | ----------- | ----------- | ----------- |----------- |----------- |----------- |
| `Future<int?> init(String path, String key)`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:      | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:    |
| `Future<List<DocumentResult>?> detect(String file)`     | :heavy_check_mark:      | :heavy_check_mark:   | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:     |:heavy_check_mark:      |
| `Future<NormalizedImage?> normalize(String file, dynamic points)`     | :heavy_check_mark:      | :heavy_check_mark:   | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:     |:heavy_check_mark:    |
| `Future<int?> save(String filename)`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:       | :heavy_check_mark:       |:heavy_check_mark:      | :heavy_check_mark:     |
| `Future<int?> setParameters(String params)`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:       | :heavy_check_mark:       |:heavy_check_mark:      | :heavy_check_mark:     |
| `Future<String?> getParameters()`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:       | :heavy_check_mark:       |:heavy_check_mark:      | :heavy_check_mark:     |

## Usage
- Initialize the document rectification SDK with resource path and license key. The resource path is only required for **web apps**:

     ```dart
    final _flutterDocumentScanSdkPlugin = FlutterDocumentScanSdk();
    await _flutterDocumentScanSdkPlugin.init(
        "https://cdn.jsdelivr.net/npm/dynamsoft-document-normalizer@1.0.11/dist/",
        "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");

    await _flutterDocumentScanSdkPlugin.setParameters(Template.grayscale);
    ```

- Do document edge detection and return quadrilaterals:

    ```dart
    List<DocumentResult>? detectionResults =
            await _flutterDocumentScanSdkPlugin
                .detect(file);
    ```
- Rectify the document based on document corners:

    ```dart
    NormalizedImage? normalizedImage = await _flutterDocumentScanSdkPlugin.normalize(
        file, detectionResults[0].points);
    ```

- Save the document to the local disk:

    ```dart
    await _flutterDocumentScanSdkPlugin
                                .save('normalized.png');
    ```



