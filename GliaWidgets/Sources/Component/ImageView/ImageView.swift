import UIKit

class ImageView: UIImageView {
    private var downloadID: String = ""
    private var environment: Environment

    init(frame: CGRect = .zero, environment: Environment) {
        self.environment = environment
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        if let image = environment.imageViewCache.getImageForKey(urlString) {
            imageReceived?(image)
            setImage(image, animated: animated) { _ in
                finished?(image)
            }
            return
        }

        let downloadID = environment.uuid().uuidString
        self.downloadID = downloadID
        environment.gcd.globalQueue.async { [weak self] in
            guard
                let data = try? self?.environment.data.dataWithContentsOfFileUrl(url),
                let image = UIImage(data: data)
            else {
                self?.environment.gcd.mainQueue.async {
                    imageReceived?(nil)
                    self?.setImage(nil, animated: animated) { _ in
                        finished?(nil)
                    }
                }
                return
            }

            self?.environment.gcd.mainQueue.async {
                self?.environment.imageViewCache.setImageForKey(image, urlString)

                guard self?.downloadID == downloadID else { return }
                imageReceived?(image)
                self?.setImage(image, animated: animated) { _ in
                    finished?(image)
                }
            }
        }
    }
}

extension ImageView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: Cache
    }
}
