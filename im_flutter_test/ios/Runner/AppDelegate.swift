import Flutter
import im_flutter_sdk_ios
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var testControlBridge: TestControlBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let sdkRegistrar = registrar(forPlugin: "ImFlutterSdkPlugin") {
      ImFlutterSdkPlugin.register(with: sdkRegistrar)
    }
    if let controlRegistrar = registrar(forPlugin: "TestControlBridge") {
      testControlBridge = TestControlBridge(registrar: controlRegistrar)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private final class TestControlBridge {
  private let channel: FlutterMethodChannel

  init(registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(
      name: "com.chat.im/test_control",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      if call.method == "getRunnerInfo" {
        result(self.runnerInfo())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func runnerInfo() -> [String: Any] {
    [
      "runnerId": argument("runnerId", fallback: "ios-runner"),
      "deviceName": argument("runnerDevice", fallback: "deviceIOS"),
      "runId": argument("runnerRunId"),
      "logicalDevice": argument("runnerLogicalDevice"),
      "artifactId": argument("runnerArtifactId"),
      "wrapperCommit": argument("runnerWrapperCommit"),
      "nativeSdkSha256": argument("runnerNativeSdkSha256"),
      "platform": "ios",
      "sdkVersion": "4.24.0",
      "appVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0",
      "topic": argument("runnerTopic"),
      "webSocketBaseUrl": argument("runnerWsBaseUrl"),
      "managedWebSocket": argument("runnerWsManaged") == "true",
    ]
  }

  private func argument(_ key: String, fallback: String = "") -> String {
    let prefix = "\(key)="
    return ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix(prefix) })
      .map { String($0.dropFirst(prefix.count)) } ?? fallback
  }
}
