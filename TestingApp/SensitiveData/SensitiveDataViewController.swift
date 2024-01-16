import UIKit
import GliaCoreSDK

final class SensitiveDataViewController: UIViewController {
    private lazy var message: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = """
        This screen emulates the integrator application screen with sensitive data.

        Be aware this screen should not be visible to the operator during Live Observation, but should be visible during screen sharing.
        """
        label.accessibilityIdentifier = "sensitiveData_message"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        GliaCore.sharedInstance.liveObservation.pause()
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        GliaCore.sharedInstance.liveObservation.resume()
        super.viewWillDisappear(animated)
    }

    private func setup() {
        view.addSubview(message)
        message.translatesAutoresizingMaskIntoConstraints = false
        [
            message.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            message.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            message.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            message.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: 20)
        ].forEach { $0.isActive = true }

        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        closeButton.accessibilityIdentifier = "sensitiveData_close"
        navigationItem.rightBarButtonItem = closeButton
    }

    @objc
    private func close(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
