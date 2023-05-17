import Foundation
@testable import GliaWidgets

extension QuickLookBased.ThumbnailGenerator {
    static let failing = Self(
        generateBestRepresentation: { _, _ in
            fail("\(Self.self).generateBestRepresentation")
        }
    )
}
