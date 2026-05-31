import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    private var webView: WKWebView!

    override func loadView() {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(self, name: "terminalInput")
        config.userContentController = controller
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cssB64 = loadBundleFileB64("xterm", ext: "css")
        let xtermB64 = loadBundleFileB64("xterm", ext: "js")
        let fitB64 = loadBundleFileB64("xterm-addon-fit", ext: "js")

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <link rel="stylesheet" href="data:text/css;base64,\(cssB64)">
        <style>
          body { margin: 0; padding: 0; background: #1a1a2e; color: #e0e0e0; font-family: 'Menlo', 'Courier New', monospace; }
          #terminal { width: 100vw; height: 100vh; }
        </style>
        </head>
        <body>
        <div id="terminal"></div>
        <script src="data:text/javascript;base64,\(xtermB64)"></script>
        <script src="data:text/javascript;base64,\(fitB64)"></script>
        <script>
          window.terminal = {
            term: null,
            fitAddon: null,
            inputBuffer: '',
            init() {
              try {
                this.term = new Terminal({
                  cursorBlink: true,
                  cursorStyle: 'block',
                  fontSize: 14,
                  fontFamily: 'Menlo, "Courier New", monospace',
                  theme: {
                    background: '#1a1a2e',
                    foreground: '#e0e0e0',
                    cursor: '#ffffff',
                    selection: '#3a3a5e'
                  }
                });
                this.fitAddon = new FitAddon.FitAddon();
                this.term.loadAddon(this.fitAddon);
                this.term.open(document.getElementById('terminal'));
                this.fitAddon.fit();
                this.term.onData(data => {
                  this.inputBuffer += data;
                  if (data === '\\r') {
                    window.webkit.messageHandlers.terminalInput.postMessage(this.inputBuffer.trim());
                    this.inputBuffer = '';
                  }
                });
                window.addEventListener('resize', () => this.fitAddon.fit());
                this.term.write('\\x1b[1;32miOpencode Terminal Ready\\x1b[0m\\r\\n');
              } catch(e) {
                document.body.style.background = '#1a1a2e';
                document.body.style.color = 'white';
                document.body.style.padding = '20px';
                document.body.style.fontFamily = 'monospace';
                document.body.innerText = 'Terminal init error: ' + e.message;
              }
            },
            appendOutput(text) {
              if (this.term) this.term.write(text);
            }
          };
          document.addEventListener('DOMContentLoaded', () => window.terminal.init());
        </script>
        </body>
        </html>
        """

        let resourcePath = Bundle.main.resourcePath ?? "/var/empty"
        webView.loadHTMLString(html, baseURL: URL(fileURLWithPath: resourcePath))

        NodeProcess.shared.onOutput = { [weak self] text in
            self?.appendToTerminal(text)
        }
        NodeProcess.shared.onError = { [weak self] text in
            self?.appendToTerminal(text)
        }
        NodeProcess.shared.start()
    }

    private func loadBundleFileB64(_ name: String, ext: String) -> String {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext),
              let data = try? Data(contentsOf: url) else {
            print("[iOpencode] WARNING: \(name).\(ext) not found in bundle")
            return ""
        }
        return data.base64EncodedString()
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
