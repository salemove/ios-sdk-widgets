import UIKit

extension CallVisualizer.VideoCallView {
    final class OperatorImageView: UIImageView {
        var props: Props = Props() {
            didSet {
                renderProps()
            }
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallView.OperatorImageView {
    struct Props: Equatable {
        let image: UIImage?
        let animated: Bool

        init(
            image: UIImage? = UIImage(),
            animated: Bool = false
        ) {
            self.image = image
            self.animated = animated
        }
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallView.OperatorImageView {
    func renderProps() {
        setImage(
            image: props.image,
            animated: props.animated
        )
    }

    func setImage(image: UIImage?, animated: Bool, completionHandler: ((Bool) -> Void)? = nil) {
        UIView.transition(
            with: self,
            duration: animated ? 0.2 : 0.0,
            options: .transitionCrossDissolve,
            animations: { self.image = image },
            completion: completionHandler
        )
    }
}
