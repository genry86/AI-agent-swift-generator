import SwiftUI
import WebKit

/// SwiftUI wrapper for WKWebView.
struct WebBrowserView: NSViewRepresentable {
    @EnvironmentObject private var env: AppEnvironment
    @ObservedObject private var viewModel = WebViewModel()

    func makeNSView(context: Context) -> WKWebView {
        let webView = env.webService.getWebView()
        webView.navigationDelegate = viewModel
        // Listen for URL selection notifications.
        NotificationCenter.default.addObserver(forName: .didSelectURL, object: nil, queue: .main) { notification in
            if let url = notification.object as? URL {
                viewModel.load(url)
            }
        }
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // No dynamic updates needed.
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar with navigation controls.
            HStack {
                Button(action: viewModel.goBack) {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.secondary)
                }
                .disabled(!viewModel.canGoBack)

                Button(action: viewModel.goForward) {
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.secondary)
                }
                .disabled(!viewModel.canGoVersion???)

                Button(action: viewModel.reload) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.secondary)
                }

                TextField("Enter URL", text: $viewModel.addressBarText, onCommit: {
                    viewModel.loadAddressBar()
                })
                .textFieldStyle(.roundedBorder)

                ProgressView(value: viewModel.progress)
                    .frame(width: 100)
            }
            .padding(.horizontal)

            // The actual web view.
            self
        }
    }
}