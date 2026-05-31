import UIKit

class TerminalViewController: UIViewController {

    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let terminalTextView = UITextView()
    private let bottomBar = UIView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var outputBuffer = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNode()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1.0)

        headerView.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        titleLabel.text = "\u{26A1} iOpencode Session"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        closeButton.setTitle("Done", for: .normal)
        closeButton.setTitleColor(UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0), for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(closeButton)

        let headerDivider = UIView()
        headerDivider.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        headerDivider.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerDivider)

        terminalTextView.backgroundColor = .clear
        terminalTextView.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        terminalTextView.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        terminalTextView.isEditable = false
        terminalTextView.isSelectable = true
        terminalTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        terminalTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(terminalTextView)

        bottomBar.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        let bottomDivider = UIView()
        bottomDivider.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(bottomDivider)

        inputField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        inputField.textColor = .white
        inputField.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        inputField.autocorrectionType = .no
        inputField.autocapitalizationType = .none
        inputField.spellCheckingType = .no
        inputField.returnKeyType = .send
        inputField.attributedPlaceholder = NSAttributedString(
            string: "Type a command...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.3)]
        )
        inputField.layer.cornerRadius = 10
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        inputField.leftViewMode = .always
        inputField.delegate = self
        inputField.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(inputField)

        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0), for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(sendButton)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            headerDivider.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerDivider.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerDivider.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            headerDivider.heightAnchor.constraint(equalToConstant: 0.5),

            terminalTextView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            terminalTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            terminalTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            terminalTextView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 60),

            bottomDivider.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            bottomDivider.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            bottomDivider.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            bottomDivider.heightAnchor.constraint(equalToConstant: 0.5),

            inputField.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 12),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputField.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor, constant: 2),
            inputField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor, constant: 2),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupNode() {
        appendOutput("\u{1B}[1;36m\u{26A1} iOpencode Terminal\u{1B}[0m\r\n")
        appendOutput("\u{1B}[1;32m✓ Session started\u{1B}[0m\r\n")
        appendOutput("\u{1B}[2mStarting Node.js...\u{1B}[0m\r\n")
        appendOutput("\u{1B}[2m--------------------------------\u{1B}[0m\r\n")

        NodeProcess.shared.onOutput = { [weak self] text in
            self?.appendOutput(text)
        }
        NodeProcess.shared.onError = { [weak self] text in
            self?.appendOutput(text)
        }
        NodeProcess.shared.start()
    }

    private func appendOutput(_ text: String) {
        let stripped = stripANSIDirect(text)
        outputBuffer += stripped
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.terminalTextView.text = self.outputBuffer
            if !self.outputBuffer.isEmpty {
                let bottom = NSRange(location: self.terminalTextView.text.count - 1, length: 1)
                self.terminalTextView.scrollRangeToVisible(bottom)
            }
        }
    }

    private func stripANSIDirect(_ text: String) -> String {
        var result = text
        let patterns = [
            "\u{1B}\\[[0-9;]*[A-Za-z]",
            "\u{1B}\\]([^\u{07}]*)\u{07}",
            "\u{1B}_([^\u{1B}]*)\u{1B}"
        ]
        for pattern in patterns {
            while let range = result.range(of: pattern, options: .regularExpression) {
                result.replaceSubrange(range, with: "")
            }
        }
        return result
    }

    @objc private func closeTapped() {
        NodeProcess.shared.stop()
        dismiss(animated: true)
    }

    @objc private func sendTapped() {
        guard let text = inputField.text, !text.isEmpty else { return }
        appendOutput("\u{1B}[1;34m$\u{1B}[0m \(text)\r\n")
        NodeProcess.shared.sendInput(text)
        inputField.text = ""
    }
}

extension TerminalViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
}