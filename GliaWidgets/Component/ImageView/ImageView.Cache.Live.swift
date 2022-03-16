import UIKit

extension ImageView.Cache {
    static let live: Self = {
        var cache: [String: UIImage] = [:]
        return .init(
            setImageForKey: { image, key in cache[key] = image },
            getImageForKey: { key in cache[key] }
        )
    }()
}
