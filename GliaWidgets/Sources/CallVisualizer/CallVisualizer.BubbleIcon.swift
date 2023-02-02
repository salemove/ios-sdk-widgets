import UIKit

extension CallVisualizer {
    final class BubbleIcon: BaseView {
        let imageView: UIImageView

        init(
            image: UIImage?,
            imageSize: CGSize,
            modifiers: @escaping (BubbleIcon) -> Void
        ) {
            self.imageView = .init(image: image).makeView()
            self.imageSize = imageSize
            self.modifiers = modifiers
            super.init()
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        override func setup() {
            super.setup()
            addSubview(imageView)
        }

        override func defineLayout() {
            super.defineLayout()

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: imageSize.width),
                imageView.heightAnchor.constraint(equalToConstant: imageSize.height),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

            modifiers(self)
        }

        // MARK: - Private

        private let imageSize: CGSize
        private let modifiers: (BubbleIcon) -> Void
    }
}
