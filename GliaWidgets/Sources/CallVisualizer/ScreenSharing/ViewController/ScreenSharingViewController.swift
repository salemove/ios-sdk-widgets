import UIKit
import SwiftUI

extension CallVisualizer {
    final class ScreenSharingViewController: UIViewController {
        let model: ScreenSharingView.Model

        // MARK: - Initialization

        init(
            model: ScreenSharingView.Model
        ) {
            self.model = model
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - View lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()
            let hostingController: UIHostingController<ScreenSharingView>
            let screenSharingView = ScreenSharingView(model: model)
            hostingController = UIHostingController(rootView: screenSharingView)
            hostingController.willMove(toParent: self)
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

        deinit {
            model.environment.log.prefixed(Self.self).info("Destroy End Screen Sharing screen")
        }
    }
}
