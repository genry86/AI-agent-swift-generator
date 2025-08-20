import SwiftUI
import WebKit
import Combine

/// ViewModel for WebBrowserView handling navigation state.
class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var progress: Double = 0.0
    @Published var addressBarText: String = ""

    private var webView: WKWebView? {
        // Find the WKWebView in the view hierarchy.
        NSApplication.shared.windows.first?.contentView?.subviews.compactMap { $0 as? WKWebView }.first
    }

    // MARK: Navigation actions
    func load(_ url: URL) {
        webView?.load(URLRequest(url: url))
        addressBarText = url.absoluteString
    }

    func loadAddressBar() {
        guard let url = URL(string: addressBarText), url.isValid else { return }
        load(url)
    }

    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func reload() { webView?.reload() }

    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        addressBarText = webView.url?.absoluteString ?? ""
    }
}