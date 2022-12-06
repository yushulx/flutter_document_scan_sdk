#include "include/flutter_document_scan_sdk/flutter_document_scan_sdk_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_document_scan_sdk_plugin.h"

void FlutterDocumentScanSdkPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_document_scan_sdk::FlutterDocumentScanSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
