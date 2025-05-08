import DynamsoftCaptureVisionRouter

import DynamsoftCore

import DynamsoftDocumentcvr

import DynamsoftLicense

import DynamsoftUtility

import Flutter

import UIKit

public class SwiftFlutterDocumentScanSdkPlugin: NSObject, FlutterPlugin, LicenseVerificationListener
{
    var completionHandlers: [FlutterResult] = []
    let cvr = CaptureVisionRouter()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_document_scan_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterDocumentScanSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public fund createNormalizedImage(_ result: CaptureResult) -> NSDictionary {
        let dictionary = NSMutableDictionary()

        if let item = normalizedResults.items?.first, item.type == .normalizedImage {
            let imageData = try? imageItem.imageData
            let width = imageData.width
            let height = imageData.height
            let stride = imageData.stride
            let format = imageData.format
            let data = imageData.bytes
            let length = data!.count
            let orientation = imageData.orientation

            dictionary.setObject(width, forKey: "width" as NSCopying)
            dictionary.setObject(height, forKey: "height" as NSCopying)
            dictionary.setObject(stride, forKey: "stride" as NSCopying)
            dictionary.setObject(format, forKey: "format" as NSCopying)
            dictionary.setObject(orientation, forKey: "orientation" as NSCopying)
            dictionary.setObject(length, forKey: "length" as NSCopying)

            var rgba: [UInt8] = [UInt8](repeating: 0, count: width * height * 4)

            if format == ImagePixelFormat.RGB_888 {
                var dataIndex = 0
                for i in 0..<height {
                    for j in 0..<width {
                        let index = i * width + j
                        rgba[index * 4] = data![dataIndex]  // red
                        rgba[index * 4 + 1] = data![dataIndex + 1]  // green
                        rgba[index * 4 + 2] = data![dataIndex + 2]  // blue
                        rgba[index * 4 + 3] = 255  // alpha
                        dataIndex += 3
                    }
                }
            } else if format == ImagePixelFormat.grayScaled || format == ImagePixelFormat.binaryInverted || format == ImagePixelFormat.binary_8 {
                var dataIndex = 0
                for i in 0..<height {
                    for j in 0..<width {
                        let index = i * width + j
                        rgba[index * 4] = data![dataIndex]
                        rgba[index * 4 + 1] = data![dataIndex]
                        rgba[index * 4 + 2] = data![dataIndex]
                        rgba[index * 4 + 3] = 255
                        dataIndex += 1
                    }
                }
            } else if format == ImagePixelFormat.binary {
                var grayscale: [UInt8] = [UInt8](repeating: 0, count: width * height)

                var index = 0
                let skip = stride * 8 - width
                var shift = 0
                var n = 1

                for i in 0..<length {
                    let b = data![i]
                    var byteCount = 7
                    while byteCount >= 0 {
                        let tmp = (b & (1 << byteCount)) >> byteCount

                        if shift < stride * 8 * n - skip {
                            if tmp == 1 {
                                grayscale[index] = 255
                            } else {
                                grayscale[index] = 0
                            }
                            index += 1
                        }

                        byteCount -= 1
                        shift += 1
                    }

                    if shift == stride * 8 * n {
                        n += 1
                    }
                }

                var dataIndex = 0
                for i in 0..<height {
                    for j in 0..<width {
                        let index = i * width + j
                        rgba[index * 4] = grayscale[dataIndex]
                        rgba[index * 4 + 1] = grayscale[dataIndex]
                        rgba[index * 4 + 2] = grayscale[dataIndex]
                        rgba[index * 4 + 3] = 255
                        dataIndex += 1
                    }
                }
            }
            dictionary.setObject(rgba, forKey: "data" as NSCopying)       
        }

        return dictionary
    }

    public func createContourList(_ result: CaptureResult) -> NSMutableArray {
        if let item = CaptureResult.items?.first, item.type == .detectedQuad {
            let detectedItem:DetectedQuadResultItem = item as! DetectedQuadResultItem
            
            let dictionary = NSMutableDictionary()

            let confidence = result.confidenceAsDocumentBoundary
            let points = result.location.points as! [CGPoint]

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

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case "init":
            completionHandlers.append(result)
            let arguments: NSDictionary = call.arguments as! NSDictionary
            let license: String = arguments.value(forKey: "key") as! String
            LicenseManager.initLicense(license, verificationDelegate: self)
        case "setParameters":
            let arguments: NSDictionary = call.arguments as! NSDictionary
            let params: String = arguments.value(forKey: "params") as! String
            let ret = cvr.setSettings(params)

            result(Int(ret))

        case "getParameters":
            if self.cvr == nil {
                result("")
                return
            }

            result(cvr.getSettings() ?? "")
        case "detectFile":
            if self.cvr == nil {
                result(.none)
                return
            }
            let arguments: NSDictionary = call.arguments as! NSDictionary
            DispatchQueue.global().async {
                let out = NSMutableArray()
                let filename: String = arguments.value(forKey: "file") as! String
                let detectedResults = self.cvr.captureFromFile(filename, templateName: "DetectDocumentBoundaries_Default")
                out = self.createContourList(detectedResults!)

                result(out)
            }
        case "detectBuffer":
            if self.cvr == nil {
                result(.none)
                return
            }

            let arguments: NSDictionary = call.arguments as! NSDictionary
            DispatchQueue.global().async {
                let out = NSMutableArray()
                let buffer: FlutterStandardTypedData =
                    arguments.value(forKey: "bytes") as! FlutterStandardTypedData
                let width: Int = arguments.value(forKey: "width") as! Int
                let height: Int = arguments.value(forKey: "height") as! Int
                let stride: Int = arguments.value(forKey: "stride") as! Int
                let format: Int = arguments.value(forKey: "format") as! Int
                let rotation: Int = arguments.value(forKey: "rotation") as! Int
                let enumImagePixelFormat = ImagePixelFormat(rawValue: format)
                let imageData = ImageData.init()
                imageData.bytes = buffer.data
                imageData.width = UInt(width)
                imageData.height = UInt(height)
                imageData.stride = UInt(stride)
                imageData.format = enumImagePixelFormat!
                imageData.orientation = rotation

                let detectedResults = self.cvr.captureFromBuffer(imageData, templateName: "DetectDocumentBoundaries_Default")
                out = self.createContourList(detectedResults!)
                result(out)
            }
        case "normalizeBuffer":
            if self.cvr == nil {
                result(.none)
                return
            }

            let arguments: NSDictionary = call.arguments as! NSDictionary

            let buffer: FlutterStandardTypedData =
                arguments.value(forKey: "bytes") as! FlutterStandardTypedData
            let width: Int = arguments.value(forKey: "width") as! Int
            let height: Int = arguments.value(forKey: "height") as! Int
            let stride: Int = arguments.value(forKey: "stride") as! Int
            let format: Int = arguments.value(forKey: "format") as! Int
            let enumImagePixelFormat = ImagePixelFormat(rawValue: format)
            let x1: Int = arguments.value(forKey: "x1") as! Int
            let y1: Int = arguments.value(forKey: "y1") as! Int
            let x2: Int = arguments.value(forKey: "x2") as! Int
            let y2: Int = arguments.value(forKey: "y2") as! Int
            let x3: Int = arguments.value(forKey: "x3") as! Int
            let y3: Int = arguments.value(forKey: "y3") as! Int
            let x4: Int = arguments.value(forKey: "x4") as! Int
            let y4: Int = arguments.value(forKey: "y4") as! Int
            let rotation: Int = arguments.value(forKey: "rotation") as! Int
            let colorMode: Int = arguments.value(forKey: "color") as! Int
            
            let imageData = ImageData()
            imageData.bytes = buffer.data
            imageData.width = UInt(width)
            imageData.height = UInt(height)
            imageData.stride = UInt(stride)
            imageData.format = enumImagePixelFormat!
            imageData.orientation = rotation

            let points = [
                CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2), CGPoint(x: x3, y: y3),
                CGPoint(x: x4, y: y4),
            ]
            let quad = Quadrilateral()
            quad.points = points

            var mode = ImageColourMode.colour

            switch colorMode {
            case 0: mode = ImageColourMode.colour
            case 1: mode = ImageColourMode.grayscale
            case 2: mode = ImageColourMode.binary 
            }
            
            if let settings = try? self.cvr.getSimplifiedSettings(name) {
                settings.documentSettings?.colourMode = mode
                settings.roi = quad
                settings.roiMeasuredInPercentage = false
                try? self.cvr.updateSettings(name, settings: settings)
            }

            DispatchQueue.global().async {
                let normalizedResults = self.cvr.captureFromBuffer(imageData, templateName: "NormalizeDocument_Default")
                let dictionary = self.createNormalizedImage(normalizedResults!)
                result(dictionary)
            }
        case "normalizeFile":
            if self.cvr == nil {
                result(.none)
                return
            }

            let arguments: NSDictionary = call.arguments as! NSDictionary

            let filename: String = arguments.value(forKey: "file") as! String
            let x1: Int = arguments.value(forKey: "x1") as! Int
            let y1: Int = arguments.value(forKey: "y1") as! Int
            let x2: Int = arguments.value(forKey: "x2") as! Int
            let y2: Int = arguments.value(forKey: "y2") as! Int
            let x3: Int = arguments.value(forKey: "x3") as! Int
            let y3: Int = arguments.value(forKey: "y3") as! Int
            let x4: Int = arguments.value(forKey: "x4") as! Int
            let y4: Int = arguments.value(forKey: "y4") as! Int
            let colorMode: Int = arguments.value(forKey: "color") as! Int

            let points = [
                CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2), CGPoint(x: x3, y: y3),
                CGPoint(x: x4, y: y4),
            ]
            let quad = Quadrilateral()
            quad.points = points

            var mode = ImageColourMode.colour

            switch colorMode {
            case 0: mode = ImageColourMode.colour
            case 1: mode = ImageColourMode.grayscale
            case 2: mode = ImageColourMode.binary 
            }

            if let settings = try? self.cvr.getSimplifiedSettings(name) {
                settings.documentSettings?.colourMode = mode
                settings.roi = quad
                settings.roiMeasuredInPercentage = false
                try? self.cvr.updateSettings(name, settings: settings)
            }

            DispatchQueue.global().async {
                let normalizedResults = self.cvr.captureFromFile(filename, templateName: "NormalizeDocument_Default")
                let dictionary = self.createNormalizedImage(normalizedResults!)
                result(dictionary)
            }
        default:
            result(.none)
        }
    }

    override init() {
        super.init()
    }

    public func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if isSuccess {
            completionHandlers.first?(0)
        } else {
            completionHandlers.first?(-1)
        }
    }
}
