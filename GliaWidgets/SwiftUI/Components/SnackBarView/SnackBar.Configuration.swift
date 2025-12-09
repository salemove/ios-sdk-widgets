import Foundation
import UIKit

extension SnackBar {
    struct Configuration {
        /// Used when we position relative to safe area.
        let baseOffset: CGFloat

        /// Optional view we want to anchor the snackbar above.
        /// If this is provided, we ignore `baseOffset` for positioning,
        /// and instead pin snackbar.bottom to `anchorView.top + anchorGap`.
        let anchorViewProvider: (() -> UIView?)?

        /// Gap between anchorView.top and snackbar.bottom (positive value).
        let anchorGap: CGFloat

        init(
            baseOffset: CGFloat,
            anchorViewProvider: (() -> UIView?)? = nil,
            anchorGap: CGFloat = 0
        ) {
            self.baseOffset = baseOffset
            self.anchorViewProvider = anchorViewProvider
            self.anchorGap = anchorGap
        }
    }
}

extension SnackBar.Configuration {
    static func anchor(
        anchorViewProvider: @escaping () -> UIView?,
        gap: CGFloat = 16
    ) -> Self {
        .init(
            baseOffset: 0,
            anchorViewProvider: anchorViewProvider,
            anchorGap: gap
        )
    }

    static let callVisualizer: SnackBar.Configuration = .init(
        baseOffset: -60
    )

    static let `default`: SnackBar.Configuration = .init(
        baseOffset: -60
    )
}
