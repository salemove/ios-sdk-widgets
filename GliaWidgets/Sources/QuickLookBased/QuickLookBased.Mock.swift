import UIKit
import QuickLook

#if DEBUG
extension QuickLookBased.ThumbnailGenerator {
    static let mock: Self = .init(generateBestRepresentation: { _, _ in })
}

extension QuickLookBased.ThumbnailRepresentation {
    static let mock: Self = .init()
}
#endif
