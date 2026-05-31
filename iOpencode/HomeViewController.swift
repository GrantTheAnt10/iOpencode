import UIKit

class HomeViewController: UIViewController {

    private let containerView = UIView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let versionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    private func setupUI() {
        let gradientLayer = CAGradientLayer()

        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.08, blue: 0.20, alpha: 1.0).cgColor,
            UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1.0).cgColor
        ]
        backgroundGradient.locations = [0.0, 0.5, 1.0]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        backgroundGradient.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient, at: 0)

        let topBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        topBlur.alpha = 0.3
        topBlur.frame = CGRect(x: -50, y: -100, width: view.bounds.width + 100, height: 200)
        topBlur.layer.cornerRadius = 100
        topBlur.clipsToBounds = true
        view.addSubview(topBlur)

        let bottomBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        bottomBlur.alpha = 0.3
        bottomBlur.frame = CGRect(x: -50, y: view.bounds.height - 100, width: view.bounds.width + 100, height: 200)
        bottomBlur.layer.cornerRadius = 100
        bottomBlur.clipsToBounds = true
        view.addSubview(bottomBlur)

        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        containerView.layer.cornerRadius = 32
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        let innerGlass = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        innerGlass.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        innerGlass.layer.cornerRadius = 24
        innerGlass.clipsToBounds = true
        innerGlass.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(innerGlass)

        logoLabel.text = "⚡ iOpencode"
        logoLabel.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        logoLabel.textColor = .white
        logoLabel.textAlignment = .center
        logoLabel.alpha = 0
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(logoLabel)

        subtitleLabel.text = "AI Coding Assistant for iOS"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        startButton.setTitle("  Start Session  ", for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        startButton.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0)
        startButton.layer.cornerRadius = 28
        startButton.alpha = 0
        startButton.layer.shadowColor = UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.5).cgColor
        startButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        startButton.layer.shadowRadius = 12
        startButton.layer.shadowOpacity = 0.4
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(startButton)

        let configButton = UIButton(type: .system)
        configButton.setTitle("  Configure  ", for: .normal)
        configButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        configButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        configButton.alpha = 0
        configButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(configButton)

        statusLabel.text = "Ready to start"
        statusLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        statusLabel.textColor = UIColor(red: 0.6, green: 1.0, blue: 0.7, alpha: 0.8)
        statusLabel.textAlignment = .center
        statusLabel.alpha = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statusLabel)

        versionLabel.text = "v1.0.0  •  Node.js Embedded"
        versionLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.25)
        versionLabel.textAlignment = .center
        versionLabel.alpha = 0
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            innerGlass.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            innerGlass.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            innerGlass.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
            innerGlass.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2),

            logoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 48),
            logoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            logoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            startButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            startButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 220),
            startButton.heightAnchor.constraint(equalToConstant: 56),

            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            configButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            configButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }

    private func animateEntrance() {
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.logoLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0.35, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.startButton.alpha = 1
            self.statusLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut) {
            self.versionLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.3, options: .curveEaseOut) {
            self.containerView.transform = .identity
        }
    }

    @objc private func startTapped() {
        let terminalVC = TerminalViewController()
        terminalVC.modalPresentationStyle = .fullScreen
        present(terminalVC, animated: true)
    }
}