import UIKit
import GliaWidgets

extension ViewController {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        #if DEBUG
        if motion == .motionShake {
            let playbook = PlaybookViewController()
            let navigationController = UINavigationController(rootViewController: playbook)
            navigationController.modalPresentationStyle = .overFullScreen
            playbook.title = "Playbook"
            present(navigationController, animated: true)
            playbook.navigationItem.leftBarButtonItem = .init(title: "Close", style: .plain, target: self, action: #selector(pop))
        }
        #endif
    }

    @objc
    private func pop() {
        presentedViewController?.dismiss(animated: true)
    }
}
