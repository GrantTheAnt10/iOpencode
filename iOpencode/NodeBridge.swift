import Foundation
import NodeMobile

class NodeProcess {
    static let shared = NodeProcess()
    var onOutput: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private var isStarted = false

    func start() {
        guard !isStarted else { return }
        isStarted = true

        let homePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let workspacePath = (homePath as NSString).appendingPathComponent("workspace")

        try? FileManager.default.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
        FileManager.default.changeCurrentDirectoryPath(workspacePath)

        setenv("HOME", workspacePath, 1)
        setenv("TMPDIR", NSTemporaryDirectory(), 1)
        setenv("TERM", "xterm-256color", 1)

        let nodeModulesPath = (workspacePath as NSString).appendingPathComponent("node_modules")
        setenv("NODE_PATH", nodeModulesPath, 1)

        DispatchQueue.global(qos: .userInitiated).async {
            self.runNode()
        }
    }

    private func runNode() {
        onOutput?("\u{1B}[1;36m⚡ iOpencode Terminal v1\u{1B}[0m\r\n")
        onOutput?("\u{1B}[2mInitializing Node.js environment...\u{1B}[0m\r\n")

        var cArgs = ["node", "-e", """
            console.log('Node.js version: ' + process.version);
            console.log('Platform: ' + process.platform);
            console.log('Cwd: ' + process.cwd());
            console.log('');
            console.log('\x1b[1;32m✓ Node.js is working!\x1b[0m');
            console.log('\x1b[1;33mReady for opencode session.\x1b[0m');
            """].map { strdup($0) } + [nil]

        cArgs.withUnsafeMutableBufferPointer { buf in
            node_start(Int32(buf.count - 1), buf.baseAddress)
        }

        DispatchQueue.main.async { [weak self] in
            self?.isStarted = false
        }
    }

    func sendInput(_ text: String) {
        onOutput?("\u{1B}[1;34m$\u{1B}[0m \(text)\r\n")
    }

    func stop() {
        isStarted = false
    }
}