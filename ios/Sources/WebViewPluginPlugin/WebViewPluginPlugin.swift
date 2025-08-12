import Capacitor
import UIKit

@objc(WebViewPluginPlugin)
public class WebViewPluginPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "WebViewPluginPlugin"
    public let jsName = "WebViewPlugin"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "openWebview", returnType: CAPPluginReturnPromise)
    ]

    @objc func openWebview(_ call: CAPPluginCall) {
        guard let url = call.getString("url"), !url.isEmpty else {
            call.reject("URL is required")
            return
        }

        DispatchQueue.main.async {
            let vc = TelemedicineViewController()
            vc.urlString = url
            vc.modalPresentationStyle = .fullScreen
            self.bridge?.viewController?.present(vc, animated: true, completion: nil)
            call.resolve()
        }
    }
}
