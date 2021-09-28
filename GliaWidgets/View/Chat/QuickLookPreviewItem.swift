import UIKit
import QuickLook

class QuickLookPreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL?
    var previewItemTitle: String?

    init(url: URL? = nil, title: String? = nil) {
        previewItemURL = url
        previewItemTitle = title
    }
}
