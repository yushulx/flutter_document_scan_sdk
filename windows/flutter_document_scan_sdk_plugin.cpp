#include "flutter_document_scan_sdk_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace flutter_document_scan_sdk
{

  // static
  void FlutterDocumentScanSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "flutter_document_scan_sdk",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<FlutterDocumentScanSdkPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  FlutterDocumentScanSdkPlugin::FlutterDocumentScanSdkPlugin()
  {
    manager = new DocumentManager();
    manager->Init();
  }

  FlutterDocumentScanSdkPlugin::~FlutterDocumentScanSdkPlugin()
  {
    delete manager;
  }

  void FlutterDocumentScanSdkPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    const auto *arguments = std::get_if<EncodableMap>(method_call.arguments());

    if (method_call.method_name().compare("getPlatformVersion") == 0)
    {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater())
      {
        version_stream << "10+";
      }
      else if (IsWindows8OrGreater())
      {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater())
      {
        version_stream << "7";
      }

      version_stream << ". Dynamsoft Document Normalizer version: ";
      version_stream << manager->GetVersion();
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else if (method_call.method_name().compare("init") == 0)
    {
      std::string license;
      int ret = 0;

      if (arguments)
      {
        auto license_it = arguments->find(EncodableValue("key"));
        if (license_it != arguments->end())
        {
          license = std::get<std::string>(license_it->second);
        }
        ret = DocumentManager::SetLicense(license.c_str());
      }

      result->Success(EncodableValue(ret));
    }
    else if (method_call.method_name().compare("setParameters") == 0)
    {
      std::string params;
      EncodableList results;
      int ret = 0;

      if (arguments)
      {
        auto params_it = arguments->find(EncodableValue("params"));
        if (params_it != arguments->end())
        {
          params = std::get<std::string>(params_it->second);
        }
        ret = manager->SetParameters(params.c_str());
      }

      result->Success(EncodableValue(ret));
    }
    else if (method_call.method_name().compare("getParameters") == 0)
    {
      result->Success(manager->GetParameters());
    }
    else if (method_call.method_name().compare("save") == 0)
    {
      std::string filename;
      EncodableList results;
      int ret = 0;

      if (arguments)
      {
        auto filename_it = arguments->find(EncodableValue("filename"));
        if (filename_it != arguments->end())
        {
          filename = std::get<std::string>(filename_it->second);
        }
        ret = manager->Save(filename.c_str());
      }

      result->Success(EncodableValue(ret));
    }
    else if (method_call.method_name().compare("detectFile") == 0)
    {
      std::string filename;
      EncodableList results;

      if (arguments)
      {
        auto filename_it = arguments->find(EncodableValue("file"));
        if (filename_it != arguments->end())
        {
          filename = std::get<std::string>(filename_it->second);
        }

        results = manager->DetectFile(filename.c_str());
      }

      result->Success(results);
    }
    else if (method_call.method_name().compare("detectBuffer") == 0)
    {
      std::vector<unsigned char> bytes;
      EncodableList results;
      int width = 0, height = 0, stride = 0, format = 0;

      if (arguments)
      {
        auto bytes_it = arguments->find(EncodableValue("bytes"));
        if (bytes_it != arguments->end())
        {
          bytes = std::get<vector<unsigned char>>(bytes_it->second);
        }

        auto width_it = arguments->find(EncodableValue("width"));
        if (width_it != arguments->end())
        {
          width = std::get<int>(width_it->second);
        }

        auto height_it = arguments->find(EncodableValue("height"));
        if (height_it != arguments->end())
        {
          height = std::get<int>(height_it->second);
        }

        auto stride_it = arguments->find(EncodableValue("stride"));
        if (stride_it != arguments->end())
        {
          stride = std::get<int>(stride_it->second);
        }

        auto format_it = arguments->find(EncodableValue("format"));
        if (format_it != arguments->end())
        {
          format = std::get<int>(format_it->second);
        }
        manager->DetectBuffer(result, reinterpret_cast<unsigned char*>(bytes.data()), width, height, stride, format);
      }
    }
    else if (method_call.method_name().compare("normalizeBuffer") == 0)
    {
      std::vector<unsigned char> bytes;
      EncodableMap results;
      int width = 0, height = 0, stride = 0, format = 0;
      int x1 = 0, y1 = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0, x4 = 0, y4 = 0;

      if (arguments)
      {
        auto bytes_it = arguments->find(EncodableValue("bytes"));
        if (bytes_it != arguments->end())
        {
          bytes = std::get<vector<unsigned char>>(bytes_it->second);
        }

        auto width_it = arguments->find(EncodableValue("width"));
        if (width_it != arguments->end())
        {
          width = std::get<int>(width_it->second);
        }

        auto height_it = arguments->find(EncodableValue("height"));
        if (height_it != arguments->end())
        {
          height = std::get<int>(height_it->second);
        }

        auto stride_it = arguments->find(EncodableValue("stride"));
        if (stride_it != arguments->end())
        {
          stride = std::get<int>(stride_it->second);
        }

        auto format_it = arguments->find(EncodableValue("format"));
        if (format_it != arguments->end())
        {
          format = std::get<int>(format_it->second);
        }

        auto x1_it = arguments->find(EncodableValue("x1"));
        if (x1_it != arguments->end())
        {
          x1 = std::get<int>(x1_it->second);
        }

        auto y1_it = arguments->find(EncodableValue("y1"));
        if (y1_it != arguments->end())
        {
          y1 = std::get<int>(y1_it->second);
        }

        auto x2_it = arguments->find(EncodableValue("x2"));
        if (x2_it != arguments->end())
        {
          x2 = std::get<int>(x2_it->second);
        }

        auto y2_it = arguments->find(EncodableValue("y2"));
        if (y2_it != arguments->end())
        {
          y2 = std::get<int>(y2_it->second);
        }

        auto x3_it = arguments->find(EncodableValue("x3"));
        if (x3_it != arguments->end())
        {
          x3 = std::get<int>(x3_it->second);
        }

        auto y3_it = arguments->find(EncodableValue("y3"));
        if (y3_it != arguments->end())
        {
          y3 = std::get<int>(y3_it->second);
        }

        auto x4_it = arguments->find(EncodableValue("x4"));
        if (x4_it != arguments->end())
        {
          x4 = std::get<int>(x4_it->second);
        }

        auto y4_it = arguments->find(EncodableValue("y4"));
        if (y4_it != arguments->end())
        {
          y4 = std::get<int>(y4_it->second);
        }

        results = manager->NormalizeBuffer(reinterpret_cast<unsigned char*>(bytes.data()), width, height, stride, format, x1, y1, x2, y2, x3, y3, x4, y4);
      }
      result->Success(results);
    }
    else if (method_call.method_name().compare("normalizeFile") == 0)
    {
      std::string filename;
      EncodableMap results;
      int x1 = 0, y1 = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0, x4 = 0, y4 = 0;

      if (arguments)
      {
        auto filename_it = arguments->find(EncodableValue("file"));
        if (filename_it != arguments->end())
        {
          filename = std::get<std::string>(filename_it->second);
        }

        auto x1_it = arguments->find(EncodableValue("x1"));
        if (x1_it != arguments->end())
        {
          x1 = std::get<int>(x1_it->second);
        }

        auto y1_it = arguments->find(EncodableValue("y1"));
        if (y1_it != arguments->end())
        {
          y1 = std::get<int>(y1_it->second);
        }

        auto x2_it = arguments->find(EncodableValue("x2"));
        if (x2_it != arguments->end())
        {
          x2 = std::get<int>(x2_it->second);
        }

        auto y2_it = arguments->find(EncodableValue("y2"));
        if (y2_it != arguments->end())
        {
          y2 = std::get<int>(y2_it->second);
        }

        auto x3_it = arguments->find(EncodableValue("x3"));
        if (x3_it != arguments->end())
        {
          x3 = std::get<int>(x3_it->second);
        }

        auto y3_it = arguments->find(EncodableValue("y3"));
        if (y3_it != arguments->end())
        {
          y3 = std::get<int>(y3_it->second);
        }

        auto x4_it = arguments->find(EncodableValue("x4"));
        if (x4_it != arguments->end())
        {
          x4 = std::get<int>(x4_it->second);
        }

        auto y4_it = arguments->find(EncodableValue("y4"));
        if (y4_it != arguments->end())
        {
          y4 = std::get<int>(y4_it->second);
        }

        results = manager->NormalizeFile(filename.c_str(), x1, y1, x2, y2, x3, y3, x4, y4);
      }

      result->Success(results);
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace flutter_document_scan_sdk
