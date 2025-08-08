import Capacitor
import WebKit
import UIKit

@objc(VumiWebviewPlugin)
public class VumiWebviewPlugin: CAPPlugin {
    @objc func openWebview(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let urlString = call.getString("url"), let url = URL(string: urlString) else {
                call.reject("URL inválida")
                return
            }

            let webViewController = TelemedicineViewController()
            webViewController.url = url
            self.bridge?.viewController?.present(webViewController, animated: true, completion: nil)

            call.resolve()
        }
    }
}
