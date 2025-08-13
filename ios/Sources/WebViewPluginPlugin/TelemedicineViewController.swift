import UIKit
import WebKit

class TelemedicineViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!
    var urlString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let headerHeight: CGFloat = 50
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

        let header = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: view.frame.width, height: headerHeight))
        header.backgroundColor = UIColor(red: 60/255, green: 84/255, blue: 134/255, alpha: 1.0) // #3C5486
        view.addSubview(header)

        let titleLabel = UILabel(frame: CGRect(x: 50, y: 0, width: view.frame.width - 100, height: headerHeight))
        titleLabel.text = "Telemedicine Service"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        header.addSubview(titleLabel)

        let backButton = UIButton(frame: CGRect(x: 10, y: 0, width: 40, height: headerHeight))
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        header.addSubview(backButton)

        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = WKWebsiteDataStore.default()

        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        } else {
            config.mediaPlaybackRequiresUserAction = false
        }

        let webViewY = statusBarHeight + headerHeight
        webView = WKWebView(frame: CGRect(x: 0, y: webViewY, width: view.frame.width, height: view.frame.height - webViewY), configuration: config)
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        webView.navigationDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true

        view.addSubview(webView)

        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
