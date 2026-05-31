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

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
        <style>
          body { margin: 0; padding: 0; background: #1a1a2e; color: #e0e0e0; font-family: 'Menlo', 'Courier New', monospace; }
          #terminal { width: 100vw; height: 100vh; }
          .xterm-viewport { scrollbar-width: thin; }
        </style>
        </head>
        <body>
        <div id="terminal"></div>
        <script>
          function loadScript(url) {
            return new Promise((resolve, reject) => {
              var s = document.createElement('script');
              s.src = url;
              s.onload = resolve;
              s.onerror = reject;
              document.head.appendChild(s);
            });
          }
          loadScript('xterm.js')
            .then(() => loadScript('xterm-addon-fit.js'))
            .then(() => {
              window.terminal = {
                term: null,
                fitAddon: null,
                inputBuffer: '',
                init() {
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
                },
                appendOutput(text) {
                  this.term.write(text);
                }
              };
              window.terminal.init();
            })
            .catch(e => {
              document.body.style.background = '#1a1a2e';
              document.body.style.color = '#ff4444';
              document.body.style.padding = '20px';
              document.body.style.fontFamily = 'monospace';
              document.body.innerText = 'Error loading terminal: ' + e;
            });
        </script>
        </body>
        </html>
        """

        guard let resourcePath = Bundle.main.resourcePath else { return }
        let baseURL = URL(fileURLWithPath: resourcePath, isDirectory: true)
        webView.loadHTMLString(html, baseURL: baseURL)

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
