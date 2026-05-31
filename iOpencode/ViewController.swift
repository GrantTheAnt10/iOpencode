import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    private var webView: WKWebView!

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        let controller = WKUserContentController()
        controller.add(self, name: "terminalInput")
        config.userContentController = controller
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = Bundle.main.url(forResource: "terminal", withExtension: "html") else {
            fatalError("terminal.html not found")
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())

        NodeProcess.shared.onOutput = { [weak self] text in
            self?.appendToTerminal(text)
        }
        NodeProcess.shared.onError = { [weak self] text in
            self?.appendToTerminal(text)
        }
        NodeProcess.shared.start()
    }

    private func appendToTerminal(_ text: String) {
        let escaped = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        webView.evaluateJavaScript("terminal.appendOutput(\"\(escaped)\")")
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "terminalInput", let text = message.body as? String else { return }
        NodeProcess.shared.sendInput(text + "\n")
    }
}
