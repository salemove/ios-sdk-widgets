import Foundation
import UIKit

extension CallVisualizer {
    final class EngagementViewController: BaseViewController<EngagementView> {}
}

extension CallVisualizer {
    final class EngagementView: BaseView {
        let title: UILabel = UILabel().makeView {
            $0.text = "Tere"
        }

        override func setup() {
            super.setup()
            addSubview(title)
        }

        override func defineLayout() {
            super.defineLayout()

            NSLayoutConstraint.activate([
                title.centerXAnchor.constraint(equalTo: centerXAnchor),
                title.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }
}
