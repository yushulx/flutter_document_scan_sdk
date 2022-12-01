#ifndef FLUTTER_PLUGIN_FLUTTER_DOCUMENT_SCAN_SDK_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_DOCUMENT_SCAN_SDK_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "include/document_manager.h"

namespace flutter_document_scan_sdk {

class FlutterDocumentScanSdkPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterDocumentScanSdkPlugin();

  virtual ~FlutterDocumentScanSdkPlugin();

  // Disallow copy and assign.
  FlutterDocumentScanSdkPlugin(const FlutterDocumentScanSdkPlugin&) = delete;
  FlutterDocumentScanSdkPlugin& operator=(const FlutterDocumentScanSdkPlugin&) = delete;

 private:
    DocumentManager *manager;
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_document_scan_sdk

#endif  // FLUTTER_PLUGIN_FLUTTER_DOCUMENT_SCAN_SDK_PLUGIN_H_
