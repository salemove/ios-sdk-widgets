import UIKit
@testable import GliaWidgets

extension AlertViewController {
    static func mock(
        kind: Kind,
        viewFactory: ViewFactory = .mock()
    ) -> AlertViewController {
        AlertViewController(
            kind: kind,
            viewFactory: viewFactory
        )
    }

    static func mock(
        kind: AlertKind,
        viewFactory: ViewFactory = .mock()
    ) -> AlertViewController {
        .mock(
            kind: .mock(kind: kind),
            viewFactory: viewFactory
        )
    }
}
