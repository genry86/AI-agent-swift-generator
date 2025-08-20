import WebKit
import Combine

/// Service wrapping WKWebView navigation.
class WebNavigationService: NSObject, ObservableObject {
    @Published var url: URL?
    @Published var title: String = ""
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0.0

    private var webView: WKWebView!

    override init() {
        super.init()
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    /// Loads the given URL.
    func load(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    /// Returns the underlying WKWebView for SwiftUI wrapper.
    func getWebView() -> WKWebView {
        return webView
    }

    // Observe progress changes.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progress = webView.estimatedProgress
        }
    }
}

// MARK: WKNavigationDelegate
extension WebNavigationService: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        title = webView.title ?? ""
        url = webView.url
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
    }
}