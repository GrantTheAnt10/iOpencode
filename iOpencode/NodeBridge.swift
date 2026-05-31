import Foundation
import NodeMobile

class NodeRunner: NSObject {
    static func startNode() {
        let wwwPath = Bundle.main.resourcePath!
        let args: [String] = ["node", wwwPath + "/index.js"]
        #if DEBUG
        print("Starting Node.js with script: \(args.last ?? "")")
        #endif
        var cArgs = args.map { strdup($0) } + [nil]
        defer { cArgs.forEach { free($0) } }
        cArgs.withUnsafeMutableBufferPointer { buf in
            node_start(Int32(buf.count - 1), buf.baseAddress)
        }
    }
}

class NodeProcess {
    static let shared = NodeProcess()
    var onOutput: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private var stdoutPipe: Pipe?
    private var stdinPipe: Pipe?

    func start() {
        let wwwPath = Bundle.main.resourcePath!
        FileManager.default.changeCurrentDirectoryPath(wwwPath)
        setenv("NODE_PATH", "\(wwwPath)/node_modules", 1)
        setenv("HOME", wwwPath, 1)
        setenv("TERM", "xterm-256color", 1)

        let outPipe = Pipe()
        let errPipe = Pipe()
        let inPipe = Pipe()
        stdoutPipe = outPipe
        stdinPipe = inPipe

        dup2(outPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(errPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        dup2(inPipe.fileHandleForReading.fileDescriptor, STDIN_FILENO)

        outPipe.fileHandleForWriting.closeFile()
        errPipe.fileHandleForWriting.closeFile()

        let outHandle = outPipe.fileHandleForReading
        let errHandle = errPipe.fileHandleForReading

        outHandle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if data.isEmpty { return }
            if let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async { self?.onOutput?(text) }
            }
        }

        errHandle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if data.isEmpty { return }
            if let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async { self?.onError?(text) }
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            NodeRunner.startNode()
        }
    }

    func sendInput(_ text: String) {
        guard let pipe = stdinPipe else { return }
        if let data = text.data(using: .utf8) {
            pipe.fileHandleForWriting.write(data)
        }
    }
}
