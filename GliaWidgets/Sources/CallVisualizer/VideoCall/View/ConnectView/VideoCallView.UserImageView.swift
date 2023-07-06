import UIKit

extension CallVisualizer.VideoCallView {
    final class UserImageView: BaseView {

        // MARK: - Properties

        var props: Props {
            didSet {
                renderProps()
            }
        }

        private var placeholderImageView = UIImageView()
        private var operatorImageView = OperatorImageView()

        private var operatorImageVisible: Bool = false {
            didSet {
                guard operatorImageVisible != oldValue else { return }
                placeholderImageView.isHidden = operatorImageVisible
                operatorImageView.isHidden = !operatorImageVisible
            }
        }

        private var renderPlaceholderImage: UIImage? {
            didSet {
                guard renderPlaceholderImage != oldValue else { return }
                placeholderImageView.image = renderPlaceholderImage
            }
        }

        // MARK: - Initializers

        init(props: Props) {
            self.props = props
            super.init()
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        // MARK: - Overrides

        override func setup() {
            super.setup()
            clipsToBounds = true
            placeholderImageView.tintColor = props.style.placeholderColor
            placeholderImageView.image = props.style.placeholderImage
            updatePlaceholderContentMode()
        }

        override func defineLayout() {
            super.defineLayout()

            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            addSubview(placeholderImageView)
            placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
            constraints += placeholderImageView.layoutInSuperview()

            addSubview(operatorImageView)
            operatorImageView.translatesAutoresizingMaskIntoConstraints = false
            constraints += operatorImageView.layoutInSuperview()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = bounds.height / 2.0
            updatePlaceholderContentMode()
            switch props.style.placeholderBackgroundColor {
            case .fill(let color):
                placeholderImageView.backgroundColor = color
            case .gradient(let colors):
                placeholderImageView.makeGradientBackground(colors: colors)
            }
            switch props.style.imageBackgroundColor {
            case .fill(let color):
                operatorImageView.backgroundColor = color
            case .gradient(let colors):
                operatorImageView.makeGradientBackground(colors: colors)
            }
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallView.UserImageView {
    struct Props: Equatable {
        let style: UserImageStyle
        let operatorImageVisible: Bool
        let placeHolderImage: UIImage?
        let operatorImageViewProps: CallVisualizer.VideoCallView.OperatorImageView.Props
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallView.UserImageView {
    func renderProps() {
        operatorImageView.props = props.operatorImageViewProps
        operatorImageVisible = props.operatorImageVisible
        renderPlaceholderImage = props.placeHolderImage
        layoutSubviews()
    }

    func updatePlaceholderContentMode() {
        guard let image = placeholderImageView.image else { return }

        if placeholderImageView.frame.size.width > image.size.width &&
            placeholderImageView.frame.size.height > image.size.height {
            placeholderImageView.contentMode = .center
        } else {
            placeholderImageView.contentMode = .scaleAspectFit
        }
    }
}
