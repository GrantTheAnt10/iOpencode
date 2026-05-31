import UIKit

class ViewController: UIViewController {
    private let textView = UITextView()
    private let inputField = UITextField()
    private let bottomBar = UIView()
    private var fullOutput = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.102, green: 0.102, blue: 0.18, alpha: 1.0)
        setupUI()

        NodeProcess.shared.onOutput = { [weak self] text in
            self?.appendOutput(text)
        }
        NodeProcess.shared.onError = { [weak self] text in
            self?.appendOutput(text)
        }

        appendOutput("\u{1B}[1;32miOpencode Terminal Ready\u{1B}[0m\r\n")
        NodeProcess.shared.start()
    }

    private func setupUI() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = UIColor(red: 0.102, green: 0.102, blue: 0.18, alpha: 1.0)
        textView.textColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0)
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(textView)

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.22, alpha: 1.0)
        view.addSubview(bottomBar)

        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
        inputField.textColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0)
        inputField.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        inputField.autocorrectionType = .no
        inputField.autocapitalizationType = .none
        inputField.spellCheckingType = .no
        inputField.returnKeyType = .send
        inputField.attributedPlaceholder = NSAttributedString(
            string: "Type command...",
            attributes: [.foregroundColor: UIColor.gray]
        )
        inputField.delegate = self
        bottomBar.addSubview(inputField)

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor(red: 0.38, green: 0.69, blue: 0.94, alpha: 1.0), for: .normal)
        sendButton.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .semibold)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        bottomBar.addSubview(sendButton)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 50),

            inputField.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 12),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputField.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 36),

            sendButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func sendTapped() {
        guard let text = inputField.text, !text.isEmpty else { return }
        NodeProcess.shared.sendInput(text + "\n")
        inputField.text = ""
    }

    private func appendOutput(_ text: String) {
        let stripped = stripANSI(text)
        fullOutput += stripped
        textView.text = fullOutput
        let bottom = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(bottom)
    }

    private func stripANSI(_ text: String) -> String {
        var result = text
        while let range = result.range(of: "\\u{1B}\\[[0-9;]*[A-Za-z]", options: .regularExpression) {
            result.replaceSubrange(range, with: "")
        }
        return result
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
}
