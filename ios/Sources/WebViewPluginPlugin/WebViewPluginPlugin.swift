import Foundation
import Capacitor
import WebKit
import AVFoundation

@objc(WebViewPluginPlugin)
public class WebViewPluginPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "WebViewPluginPlugin"
    public let jsName = "WebViewPlugin"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "openWebview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestWebViewPermissions", returnType: CAPPluginReturnPromise)
    ]

    private var webViewNavigationController: UINavigationController?

    @objc func openWebview(_ call: CAPPluginCall) {
        guard let url = call.getString("url") else {
            call.reject("URL es requerida")
            return
        }

        DispatchQueue.main.async {
            let userAgent = call.getString("userAgent")
            let allowJavaScript = call.getBool("allowJavaScript", true)
            let allowGeolocation = call.getBool("allowGeolocation", true)
            let allowMediaPlayback = call.getBool("allowMediaPlayback", true)
            let debugEnabled = call.getBool("debugEnabled", false)
            let selectPlugin = call.getString("selectPlugin") ?? "A"
            let title = call.getString("title") ?? "Video WebView"

            let videoWebViewController: UIViewController

            switch selectPlugin {
            case "A":
                let controller = TelemedicineViewController()
                controller.configure(
                    url: url,
                    userAgent: userAgent,
                    allowJavaScript: allowJavaScript,
                    allowGeolocation: allowGeolocation,
                    allowMediaPlayback: allowMediaPlayback,
                    debugEnabled: debugEnabled,
                    title: "\(title) (Plugin: \(selectPlugin))"
                )
                videoWebViewController = controller

            case "B":
                let controller = BasicViewController()
                controller.configure(
                    url: url,
                    userAgent: userAgent,
                    allowJavaScript: allowJavaScript,
                    allowGeolocation: allowGeolocation,
                    allowMediaPlayback: allowMediaPlayback,
                    debugEnabled: debugEnabled,
                    title: "\(title) (Plugin: \(selectPlugin))"
                )
                videoWebViewController = controller

            default:
                let controller = TelemedicineViewController()
                controller.configure(
                    url: url,
                    userAgent: userAgent,
                    allowJavaScript: allowJavaScript,
                    allowGeolocation: allowGeolocation,
                    allowMediaPlayback: allowMediaPlayback,
                    debugEnabled: debugEnabled,
                    title: "\(title) (Plugin: \(selectPlugin))"
                )
                videoWebViewController = controller
            }

            let navigationController = UINavigationController(rootViewController: videoWebViewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.webViewNavigationController = navigationController

            self.bridge?.viewController?.present(navigationController, animated: true)
            call.resolve()
        }
    }

    @objc func closeVideoWebview(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.webViewNavigationController?.dismiss(animated: true) {
                self.webViewNavigationController = nil
            }
            call.resolve()
        }
    }

    @objc func checkWebViewPermissions(_ call: CAPPluginCall) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)

        let result: [String: String] = [
            "camera": authorizationStatusToString(cameraStatus),
            "microphone": authorizationStatusToString(microphoneStatus)
        ]

        call.resolve(result)
    }

    @objc func requestWebViewPermissions(_ call: CAPPluginCall) {
        let group = DispatchGroup()
        var cameraResult = "denied"
        var microphoneResult = "denied"

        // Solicitar permiso de cámara
        group.enter()
        AVCaptureDevice.requestAccess(for: .video) { granted in
            cameraResult = granted ? "granted" : "denied"
            group.leave()
        }

        // Solicitar permiso de micrófono
        group.enter()
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            microphoneResult = granted ? "granted" : "denied"
            group.leave()
        }

        group.notify(queue: .main) {
            let result: [String: String] = [
                "camera": cameraResult,
                "microphone": microphoneResult
            ]
            call.resolve(result)
        }
    }

    @objc func setWebviewOptions(_ call: CAPPluginCall) {
        let allowThirdPartyCookies = call.getBool("allowThirdPartyCookies", true)
        let allowLocalStorage = call.getBool("allowLocalStorage", true)
        let allowPopups = call.getBool("allowPopups", false)
        let allowZoom = call.getBool("allowZoom", false)

        // Guardar opciones en UserDefaults
        UserDefaults.standard.set(allowThirdPartyCookies, forKey: "VideoWebview_allowThirdPartyCookies")
        UserDefaults.standard.set(allowLocalStorage, forKey: "VideoWebview_allowLocalStorage")
        UserDefaults.standard.set(allowPopups, forKey: "VideoWebview_allowPopups")
        UserDefaults.standard.set(allowZoom, forKey: "VideoWebview_allowZoom")

        call.resolve()
    }

    private func authorizationStatusToString(_ status: AVAuthorizationStatus) -> String {
        switch status {
            case .authorized:
                return "granted"
            case .denied, .restricted:
                return "denied"
            case .notDetermined:
                return "prompt"
            @unknown default:
                return "prompt"
        }
    }
}
