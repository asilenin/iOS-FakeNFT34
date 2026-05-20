import SwiftUI
@preconcurrency import WebKit

struct WebViewRepresentable: UIViewRepresentable {

    let url: URL

    /// Optional binding the view writes `true/false` into while a page is loading. 
    /// Lets the host show a spinner or disable controls.
    var isLoading: Binding<Bool>?

    /// Optional binding the view writes the load progress into, n the range 0.0...1.0.
    var progress: Binding<Double>?

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        // Observe `estimatedProgress` via KVO. 
        // The token lives on the coordinator and is invalidated in dismantleUIView.
        context.coordinator.observation = view.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [progress] _, change in
            guard let value = change.newValue else { return }
            Task { @MainActor in
                progress?.wrappedValue = value
            }
        }
        // Initial load — happens once, in makeUIView.
        view.load(URLRequest(url: url))
        context.coordinator.lastLoadedURL = url
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Reload only when the *requested* URL changed, comparing to what
        // we last asked WKWebView to load — not to `uiView.url`,
        // which can drift after redirects, trailing-slash normalization, anchor changes,
        // etc., and would otherwise cause a reload loop.
        if context.coordinator.lastLoadedURL != url {
            uiView.load(URLRequest(url: url))
            context.coordinator.lastLoadedURL = url
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        coordinator.observation?.invalidate()
        coordinator.observation = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {

        var parent: WebViewRepresentable
        var observation: NSKeyValueObservation?
        var lastLoadedURL: URL?

        init(parent: WebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading?.wrappedValue = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading?.wrappedValue = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading?.wrappedValue = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading?.wrappedValue = false
        }
    }
}
