import UIKit

final class SendingMessageUnavailableBannerView: UIView {
    private static let horizontalMargins = 16.0
    private static let verticalMargins = 8.0

    private let label = UILabel()
    private let icon = UIImageView(image: Asset.sendMessageUnavailableInfo.image)

    private var contentConstraints: [NSLayoutConstraint] = []
    private var zeroHeightConstraint: NSLayoutConstraint!

    var props = Props.initial {
        didSet {
            guard props != oldValue else { return }
            renderProps()
        }
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0

        addSubview(icon)

        contentConstraints = [
            icon.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -8),
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1.0),
            label.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Self.horizontalMargins),
            label.topAnchor.constraint(equalTo: topAnchor, constant: Self.verticalMargins),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.verticalMargins)
        ]
        NSLayoutConstraint.activate(contentConstraints)

        zeroHeightConstraint = heightAnchor.constraint(equalToConstant: 0)
        zeroHeightConstraint.isActive = false

        renderProps()
    }

    private func renderProps() {
        label.text = props.style.message
        label.textColor = props.style.textColor
        backgroundColor = props.style.backgroundColor.color
        label.font = props.style.font
        icon.tintColor = props.style.iconColor

        if props.isHidden {
            label.isHidden = true
            icon.isHidden = true

            NSLayoutConstraint.deactivate(contentConstraints)
            zeroHeightConstraint.isActive = true
        } else {
            zeroHeightConstraint.isActive = false
            NSLayoutConstraint.activate(contentConstraints)

            label.isHidden = false
            icon.isHidden = false
        }
    }
}

extension SendingMessageUnavailableBannerView {
    struct Props: Equatable {
        let style: SendingMessageUnavailableBannerViewStyle
        let isHidden: Bool
    }
}

extension SendingMessageUnavailableBannerView.Props {
    fileprivate static let initial = Self(style: .initial, isHidden: false)
}
