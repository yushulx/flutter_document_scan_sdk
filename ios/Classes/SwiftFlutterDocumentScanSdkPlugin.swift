import Flutter
import UIKit
import DynamsoftCore
import DynamsoftDocumentNormalizer

public class SwiftFlutterDocumentScanSdkPlugin: NSObject, FlutterPlugin, LicenseVerificationListener {
  var completionHandlers: [FlutterResult] = []
  private var normalizer: DynamsoftDocumentNormalizer?
  private var normalizedImage: iNormalizedImageResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_document_scan_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterDocumentScanSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.arguments == nil {
        result(.none)
        return
    }

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
            let isSuccess = try? self.normalizer.initRuntimeSettingsFromString(params)
            if isSuccess! {
                result(0)
            } else {
                result(-1)
            }
        case "getParameters":
            let parameters: String = ""
            if self.normalizer == nil {
                result(.none)
                return
            }
            parameters = try? normalizer.outputRuntimeSettings("")
            result(parameters)
        case "detect":
            if self.normalizer == nil {
                result(.none)
                return
            }

            DispatchQueue.global().async {
                let out = NSMutableArray()
                let filename: String = arguments.value(forKey: "file") as! String
                let detectedResults = try? self.normalizer.detectQuadFromFile(filename)

                if detectedResults != nil {
                    for result in detectedResults! {
                        let dictionary = NSMutableDictionary()

                        let confidence = result.confidenceAsDocumentBoundary
                        let points = result.location!.points as! [CGPoint]

                        dictionary.setObject(confidence, forKey: "confidence" as NSCopying)
                        dictionary.setObject(Int(points[0].x), forKey: "x1" as NSCopying)
                        dictionary.setObject(Int(points[0].y), forKey: "y1" as NSCopying)
                        dictionary.setObject(Int(points[1].x), forKey: "x2" as NSCopying)
                        dictionary.setObject(Int(points[1].y), forKey: "y2" as NSCopying)
                        dictionary.setObject(Int(points[2].x), forKey: "x3" as NSCopying)
                        dictionary.setObject(Int(points[2].y), forKey: "y3" as NSCopying)
                        dictionary.setObject(Int(points[3].x), forKey: "x4" as NSCopying)
                        dictionary.setObject(Int(points[3].y), forKey: "y4" as NSCopying)

                        out.add(dictionary)
                    }
                }
                result(out)
            }
        case "normalize":
            if self.normalizer == nil {
                result(.none)
                return
            }

            result(.none)
        case "save":
            if self.normalizedImage == nil {
                result(-1)
                return
            }

            let filename: String = arguments.value(forKey: "filename") as! String
            let isSuccess = try? self.normalizedImage.saveToFile(filename)

            if isSuccess! {
                result(0)
            } else {
                result(-1)
            }
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
