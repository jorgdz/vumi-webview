import Foundation
import WebKit
import UIKit

class TelemedicineViewController: UIViewController {

    private var webView: WKWebView!
    private var url: String?
    private var userAgent: String?
    private var allowJavaScript = true
    private var allowGeolocation = true
    private var allowMediaPlayback = true
    private var debugEnabled = false
    private var webviewTitle = "Video WebView"

    public func configure(
        url: String,
        userAgent: String?,
        allowJavaScript: Bool,
        allowGeolocation: Bool,
        allowMediaPlayback: Bool,
        debugEnabled: Bool,
        title: String
    ) {
        self.url = url
        self.userAgent = userAgent
        self.allowJavaScript = allowJavaScript
        self.allowGeolocation = allowGeolocation
        self.allowMediaPlayback = allowMediaPlayback
        self.debugEnabled = debugEnabled
        self.webviewTitle = title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupWebView()
        
        if let urlString = url, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    private func setupUI() {
        title = webviewTitle
        view.backgroundColor = .systemBackground

        let color = UIColor(red: 60/255, green: 84/255, blue: 134/255, alpha: 1.0)

        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = color
            navBar.backgroundColor = color

            navBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBar.tintColor = .white
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(closeWebView)
        )
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        // Configurar preferencias
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = allowJavaScript
        config.defaultWebpagePreferences = preferences

        // Configurar para videollamadas (basado en Air Doctor)
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.websiteDataStore = WKWebsiteDataStore.default()

        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = allowMediaPlayback ? [] : .all
        } else {
            config.mediaPlaybackRequiresUserAction = false
        }

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // User Agent personalizado
        if let userAgent = userAgent {
            webView.customUserAgent = userAgent
        } else {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        }

        // Debug
        if debugEnabled {
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            }
        }

        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeWebView() {
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension TelemedicineViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Manejar esquemas especiales
        let scheme = url.scheme?.lowercased()
        if scheme == "tel" || scheme == "mailto" || scheme == "whatsapp" {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension TelemedicineViewController: WKUIDelegate {
    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        // Otorgar permisos automáticamente si la app tiene los permisos del sistema
        decisionHandler(.grant)
    }

    // Fallback para iOS 13-14
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = defaultText
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completionHandler(nil)
        })
        present(alert, animated: true)
    }

    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
}
