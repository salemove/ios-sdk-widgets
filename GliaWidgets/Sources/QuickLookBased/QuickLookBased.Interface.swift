import Foundation
import QuickLook
import UIKit

enum QuickLookBased {
    struct ThumbnailGenerator {
        var generateBestRepresentation: (QLThumbnailGenerator.Request, @escaping (QuickLookBased.ThumbnailRepresentation?, Error?) -> Void) -> Void
    }
}

extension QuickLookBased {
    struct ThumbnailRepresentation {
        var uiImage: UIImage?
    }
}
