import Foundation
import WebKit
import UIKit
import AVFoundation

class ImproveViewController: UIViewController {

    private var webView: WKWebView!
    private var url: String?
    private var userAgent: String?
    private var allowJavaScript = true
    private var popupWebView: WKWebView?
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

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .videoChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            if debugEnabled {
                print("Error configuring audio session: \(error)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAudioSession()
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
        let userContentController = WKUserContentController()

        // Configurar preferencias
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = allowJavaScript
        config.defaultWebpagePreferences = preferences

        if let scriptPath = Bundle(for: WebViewPluginPlugin.self).path(forResource: "adapter-latest", ofType: "js"),
           let scriptSource = try? String(contentsOfFile: scriptPath, encoding: .utf8) {

            let adapterScript = WKUserScript(
                source: scriptSource,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            userContentController.addUserScript(adapterScript)
        }

        config.userContentController = userContentController

        // Configurar para videollamadas
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = allowMediaPlayback ? [] : .all
        config.allowsPictureInPictureMediaPlayback = true

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
        // Limpiar audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            if debugEnabled {
                print("Error deactivating audio session: \(error.localizedDescription)")
            }
        }

        dismiss(animated: true)
    }

    deinit {
        // Asegurar limpieza al destruir el controller
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// MARK: - WKNavigationDelegate
extension ImproveViewController: WKNavigationDelegate {
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
extension ImproveViewController: WKUIDelegate {

    // Manejo de permisos de captura de media para iOS 15+
    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {

        // Verificar permisos del sistema antes de otorgar al WebView
        let mediaType: AVMediaType = (type == .camera) ? .video : .audio
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)

        switch status {
        case .authorized:
            decisionHandler(.grant)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                DispatchQueue.main.async {
                    decisionHandler(granted ? .grant : .deny)
                }
            }
        case .denied, .restricted:
            decisionHandler(.deny)
            showPermissionAlert(for: mediaType)
        @unknown default:
            decisionHandler(.deny)
        }
    }

    // Manejo de popups (necesario para algunas implementaciones de videollamadas)
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame == nil || !navigationAction.targetFrame!.isMainFrame {
            // Cargar en el WebView actual en lugar de abrir popup
            webView.load(navigationAction.request)
        }

        return nil
    }

    private func showPermissionAlert(for mediaType: AVMediaType) {
        let message = mediaType == .video
            ? "Please enable camera access in Settings > Privacy > Camera"
            : "Please enable microphone access in Settings > Privacy > Microphone"

        let alert = UIAlertController(title: "Permission Required", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Configuration", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })

        present(alert, animated: true)
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

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
}
