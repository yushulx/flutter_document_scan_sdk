import Flutter
import UIKit
import DynamsoftCore
import DynamsoftDocumentNormalizer

public class SwiftFlutterDocumentScanSdkPlugin: NSObject, FlutterPlugin, LicenseVerificationListener {
  var completionHandlers: [FlutterResult] = []
  private var normalizer: DynamsoftDocumentNormalizer?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_document_scan_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterDocumentScanSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments: NSDictionary = call.arguments as! NSDictionary
    switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "init":
            completionHandlers.append(result)
            let license: String = arguments.value(forKey: "key") as! String
            DynamsoftLicenseManager.initLicense(license, verificationDelegate: self)
        case "setParameters":
            let params: String = arguments.value(forKey: "params") as! String
            result(0)
        case "getParameters":
            let parameters: String = ""
            if self.recognizer == nil {
                result(.none)
                return
            }
            
            result(parameters)
        case "detect":
            if recognizer == nil {
                result(.none)
                return
            }

            DispatchQueue.global().async {
                // let filename: String = arguments.value(forKey: "filename") as! String
                // let res = try? self.recognizer!.recognizeFile(filename)
                // result(self.wrapResults(results: res))
                result(.none)
            }
        case "normalize":
            if self.recognizer == nil {
                result(.none)
                return
            }

            result(.none)
        case "save":
            if self.recognizer == nil {
                result(0)
                return
            }

            result(0)
        default:
            result(.none)
        }
  }

  override init() {
    super.init()
    normalizer = DynamsoftDocumentNormalizer()
  }

  public func licenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
    if isSuccess {
        completionHandlers.first?(0)
    } else{
        completionHandlers.first?(-1)
    }
  }
}
