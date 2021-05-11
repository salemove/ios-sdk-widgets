import UIKit

class ImageView: UIImageView {
    private static var cache = [String: UIImage]()
    private var downloadID: String = ""

    func setImage(_ image: UIImage?, animated: Bool, completionHandler: ((Bool) -> Void)? = nil) {
        UIView.transition(
            with: self,
            duration: animated ? 0.2 : 0.0,
            options: .transitionCrossDissolve,
            animations: { self.image = image },
            completion: completionHandler
        )
    }

    func setImage(
        from url: String?,
        animated: Bool,
        imageReceived: ((UIImage?) -> Void)? = nil,
        finished: ((UIImage?) -> Void)? = nil
    ) {
        guard
            let urlString = url,
            let url = URL(string: urlString)
        else {
            imageReceived?(nil)
            setImage(nil, animated: animated) { _ in
                finished?(nil)
            }
            return
        }

        if let image = ImageView.cache[urlString] {
            imageReceived?(image)
            setImage(image, animated: animated) { _ in
                finished?(image)
            }
            return
        }

        let downloadID = UUID().uuidString
        self.downloadID = downloadID

        DispatchQueue.global().async { [weak self] in
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    imageReceived?(nil)
                    self?.setImage(nil, animated: animated) { _ in
                        finished?(nil)
                    }
                }
                return
            }

            DispatchQueue.main.async {
                ImageView.cache[urlString] = image

                guard self?.downloadID == downloadID else { return }
                imageReceived?(image)
                self?.setImage(image, animated: animated) { _ in
                    finished?(image)
                }
            }
        }
    }
}
