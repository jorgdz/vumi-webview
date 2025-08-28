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

        let headerHeight: CGFloat = 50
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

        let header = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: view.frame.width, height: headerHeight))
        header.backgroundColor = UIColor(red: 60/255, green: 84/255, blue: 134/255, alpha: 1.0) // #3C5486
        view.addSubview(header)

        let titleLabel = UILabel(frame: CGRect(x: 50, y: 0, width: view.frame.width - 100, height: headerHeight))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        header.addSubview(titleLabel)

        let backButton = UIButton(frame: CGRect(x: 10, y: 0, width: 40, height: headerHeight))
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        header.addSubview(backButton)
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        
        // Configurar preferencias
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = allowJavaScript
        config.defaultWebpagePreferences = preferences

        // Configurar para videollamadas (basado en Air Doctor)
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = allowMediaPlayback ? [] : .all
        
        // Configurar geolocalización
        if allowGeolocation {
            config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        }

        // Obtener opciones adicionales de UserDefaults
        let allowZoom = UserDefaults.standard.bool(forKey: "VideoWebview_allowZoom")
        if !allowZoom {
            let source = """
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                var head = document.getElementsByTagName('head')[0];
                head.appendChild(meta);
            """
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            config.userContentController.addUserScript(script)
        }

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // User Agent personalizado
        if let userAgent = userAgent {
            webView.customUserAgent = userAgent
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

    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
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
