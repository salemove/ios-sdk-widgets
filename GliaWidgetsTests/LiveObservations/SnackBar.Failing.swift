import Foundation
@testable import GliaWidgets

extension SnackBar {
    static let failing = Self { _, _, _, _, _, _ in
        fail("\(Self.self).present")
    }
}
