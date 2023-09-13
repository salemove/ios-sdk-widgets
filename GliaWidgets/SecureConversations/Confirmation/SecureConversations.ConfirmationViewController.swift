import UIKit
import SwiftUI

extension SecureConversations {
    final class ConfirmationViewController: UIViewController {
        private let model: ConfirmationViewSwiftUI.Model

        init(
            model: ConfirmationViewSwiftUI.Model
        ) {
            self.model = model
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func loadView() {
            super.loadView()
            let hostingController: UIHostingController<ConfirmationViewSwiftUI>
            let confirmationView = ConfirmationViewSwiftUI(
                model: model
            )

            hostingController = UIHostingController(rootView: confirmationView)
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
}
