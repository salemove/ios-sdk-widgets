import UIKit

private extension CGFloat {
    static let spacing: CGFloat = 16
    static let contentWidth: CGFloat = 202
}

final class GvaGalleryCardView: BaseView {
    var props: Props = .nop {
        didSet {
            renderProps()
        }
    }
    private let imageSize = CGSize(width: .contentWidth, height: 143)
    private let contentInsets = UIEdgeInsets(top: .spacing, left: .spacing, bottom: .spacing, right: .spacing)
    private lazy var titleLabel = UILabel().make { $0.numberOfLines = 0 }
    private lazy var descriptionLabel = UILabel().make { $0.numberOfLines = 0 }
    private lazy var contentStack = UIStackView.make(.vertical, spacing: .spacing)(
        mainContentStack,
        buttonContentStack
    )
    private lazy var mainContentStack = UIStackView.make(.vertical, spacing: .spacing)(
        titleLabel,
        descriptionLabel
    )
    private lazy var buttonContentStack = UIStackView.make(.vertical, spacing: .spacing)()
    private var imageView: ImageView?

    override func setup() {
        super.setup()
        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.layoutInSuperview(insets: contentInsets).activate()
        contentStack.match(.width, value: .contentWidth).activate()
    }

    // Used to calculate the largest card height before laying it out
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height: CGFloat = 0
        height += contentInsets.top
        if props.image != nil {
            height += imageSize.height
            height += mainContentStack.spacing
        }
        let size = CGSize(
            width: .contentWidth,
            height: CGFloat.greatestFiniteMagnitude
        )
        height += titleLabel.sizeThatFits(size).height

        if props.subtitle != nil {
            height += mainContentStack.spacing
            height += descriptionLabel.sizeThatFits(size).height
        }

        if !props.options.isEmpty {
            height += contentStack.spacing
        }

        let count = CGFloat(props.options.count)
        height += count * GvaPersistentButtonOptionView.height
        height += max(0, count - 1) * buttonContentStack.spacing
        height += contentInsets.bottom

        return .init(width: .contentWidth, height: height)
    }
}

// MARK: - Private

private extension GvaGalleryCardView {
    func renderProps() {
        let style = props.style

        // Container
        layer.cornerRadius = style.cardContainer.cornerRadius
        switch style.cardContainer.backgroundColor {
        case let .fill(color):
            backgroundColor = color
        case let .gradient(colors):
            makeGradientBackground(colors: colors)
        }

        // Labels
        titleLabel.text = props.title
        titleLabel.font = style.title.font
        titleLabel.textColor = style.title.textColor

        descriptionLabel.text = props.subtitle
        descriptionLabel.isHidden = props.subtitle == nil
        descriptionLabel.font = style.subtitle.font
        descriptionLabel.textColor = style.subtitle.textColor

        // Image
        if let image = props.image {
            let imageView = self.imageView ?? ImageView(environment: image.environment)
            self.imageView = imageView
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.match(.height, value: imageSize.height).activate()
            mainContentStack.insertArrangedSubview(imageView, at: 0)

            imageView.setImage(from: image.url.absoluteString, animated: false)
            imageView.layer.cornerRadius = style.imageView.cornerRadius
            switch style.imageView.backgroundColor {
            case let .fill(color):
                imageView.backgroundColor = color
            case let .gradient(colors):
                imageView.makeGradientBackground(colors: colors)
            }
        } else {
            imageView?.removeFromSuperview()
        }

        // Buttons
        buttonContentStack.isHidden = props.options.isEmpty
        buttonContentStack.removeArrangedSubviews()
        props.options.forEach { option in
            let optionView = GvaPersistentButtonOptionView(
                style: .init(
                    textFont: style.button.title.font,
                    textColor: style.button.title.textColor,
                    backgroundColor: style.button.background.backgroundColor,
                    cornerRadius: style.button.background.cornerRadius,
                    borderColor: style.button.background.borderColor,
                    borderWidth: style.button.background.cornerRadius
                ),
                text: option.title
            )
            optionView.tap = option.action.execute
            buttonContentStack.addArrangedSubview(optionView)
        }
    }
}

// MARK: - Props

extension GvaGalleryCardView {
    struct Props {
        let title: String
        let subtitle: String?
        let image: Image?
        let options: [Option]
        let style: GvaGalleryCardStyle

        static var nop: Props {
            .init(
                title: "",
                subtitle: nil,
                image: nil,
                options: [],
                style: .initial
            )
        }
    }
}

extension GvaGalleryCardView.Props {
    struct Option {
        let title: String
        let action: Cmd

        static var nop: Option { .init(title: "", action: .nop) }
    }
}

extension GvaGalleryCardView.Props {
    struct Image {
        let url: URL
        let environment: ImageView.Environment
    }
}
