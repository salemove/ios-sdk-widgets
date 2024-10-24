import UIKit

final class SendingMessageUnavailableBannerView: UIView {
    private static let horizontalMargins = 16.0
    private static let verticalMargins = 8.0

    private let label = UILabel().makeView()
    private let icon = UIImageView(image: Asset.sendMessageUnavailableInfo.image).makeView()

    private lazy var visibleConstraints: [NSLayoutConstraint] = [
        icon.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -8),
        icon.centerYAnchor.constraint(equalTo: label.centerYAnchor),
        icon.widthAnchor.constraint(equalToConstant: 16),
        icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1.0),
        label.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: 40),
        label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Self.horizontalMargins),
        label.topAnchor.constraint(equalTo: topAnchor, constant: Self.verticalMargins),
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.verticalMargins)
    ]

    private lazy var invisibleConstraints: [NSLayoutConstraint] = [
        self.heightAnchor.constraint(lessThanOrEqualToConstant: 0)
    ]

    var props = Props.initial {
        didSet {
            guard props != oldValue else {
                return
            }
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
        label.numberOfLines = 0

        addSubview(icon)

        renderHidden(isHidden)
        renderProps()
    }

    override var isHidden: Bool {
        didSet {
            super.isHidden = self.isHidden
            guard isHidden != oldValue else {
                return
            }
            renderHidden(self.isHidden)
        }
    }

    private func renderHidden(_ hidden: Bool) {
        // In order to avoid breaking auto-layout constraints
        // we deactivate relevant constraints if view gets hidden
        // and activate zero-height constraints.
        if hidden {
            NSLayoutConstraint.deactivate(visibleConstraints)
            NSLayoutConstraint.activate(invisibleConstraints)
        } else {
            NSLayoutConstraint.deactivate(invisibleConstraints)
            NSLayoutConstraint.activate(visibleConstraints)
        }
        // Layout manually to enforce constraints to be applied immediately,
        // thus affecting the `frame`.
        layoutIfNeeded()
    }

    private func renderProps() {
        label.text = props.style.message
        label.textColor = props.style.textColor
        backgroundColor = props.style.backgroundColor.color
        label.font = props.style.font
        icon.tintColor = props.style.iconColor
        isHidden = props.isHidden
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
