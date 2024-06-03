import UIKit
@testable import GliaWidgets

extension AlertViewController {
    static func mock(
        type: AlertType,
        viewFactory: ViewFactory = .mock()
    ) -> AlertViewController {
        AlertViewController(
            type: type,
            viewFactory: viewFactory
        )
    }
}
