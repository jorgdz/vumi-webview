import UIKit
import WebKit

class TelemedicineViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

  var webView: WKWebView!
  var urlString: String = ""

  override func viewDidLoad() {
    super.viewDidLoad()

    let header = UILabel(frame: CGRect(x: 0, y: 40, width: view.frame.width, height: 50))
    header.text = "Telemedicine Service"
    header.textAlignment = .center
    header.backgroundColor = UIColor.systemBlue
    header.textColor = .white
    view.addSubview(header)

    let config = WKWebViewConfiguration()
    config.mediaTypesRequiringUserActionForPlayback = []
    config.allowsInlineMediaPlayback = true

    webView = WKWebView(frame: CGRect(x: 0, y: 90, width: view.frame.width, height: view.frame.height - 90), configuration: config)
    webView.uiDelegate = self
    webView.navigationDelegate = self
    webView.configuration.preferences.javaScriptEnabled = true

    view.addSubview(webView)

    if let url = URL(string: urlString) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
  }
}
