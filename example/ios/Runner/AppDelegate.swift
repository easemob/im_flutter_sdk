import UIKit
import Flutter
import im_flutter_sdk

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
//      Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { t in
//          if(self.hasPlugin("ImFlutterSdkPlugin")) {
//              print("find")
//              let wrapper = self.valuePublished(byPlugin: "ImFlutterSdkPlugin") as! EMClientWrapper
//              wrapper.sendData(toFlutter: ["key":"value"])
//          }else {
//              print("no find")
//          }
//      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
