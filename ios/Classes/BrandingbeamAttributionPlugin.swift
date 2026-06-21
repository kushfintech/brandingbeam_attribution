import Flutter
import UIKit

public class BrandingbeamAttributionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "brandingbeam_attribution", binaryMessenger: registrar.messenger())
    let instance = BrandingbeamAttributionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getInstallContext":
      // iOS has no install referrer; deferred matching is probabilistic server-side.
      // We provide the IDFV and device signals as weak match inputs.
      let context: [String: Any?] = [
        "platform": "ios",
        "deviceModel": UIDevice.current.model,
        "osVersion": UIDevice.current.systemVersion,
        "idfv": UIDevice.current.identifierForVendor?.uuidString,
      ]
      result(context.compactMapValues { $0 })
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
