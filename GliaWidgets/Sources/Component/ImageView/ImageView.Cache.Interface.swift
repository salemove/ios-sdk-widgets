import UIKit

extension ImageView {
    struct Cache {
        var setImageForKey: (UIImage?, String) -> Void
        var getImageForKey: (String) -> UIImage?
    }
}
