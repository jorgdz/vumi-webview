import UIKit
import WebKit

class TelemedicineViewController: UIViewController, WKNavigationDelegate {

  var webView: WKWebView!
  var url: URL!

  override func viewDidLoad() {
    super.viewDidLoad()

    let headerView = UIView()
    headerView.backgroundColor = UIColor.systemBlue
    headerView.translatesAutoresizingMaskIntoConstraints = false

    let titleLabel = UILabel()
    titleLabel.text = "Telemedicine Service"
    titleLabel.textColor = .white
    titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let closeButton = UIButton(type: .system)
    closeButton.setTitle("Cerrar", for: .normal)
    closeButton.setTitleColor(.white, for: .normal)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)

    headerView.addSubview(titleLabel)
    headerView.addSubview(closeButton)

    self.view.addSubview(headerView)

    let config = WKWebViewConfiguration()
    config.mediaTypesRequiringUserActionForPlayback = []
    config.allowsInlineMediaPlayback = true

    webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = self
    webView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(webView)

    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: view.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      headerView.heightAnchor.constraint(equalToConstant: 60),

      titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

      closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
      closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

      webView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    let request = URLRequest(url: url)
    webView.load(request)
  }

  @objc func closePressed() {
    dismiss(animated: true, completion: nil)
  }
}
