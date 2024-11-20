import UIKit

final class SecureMessagingBottomBannerView: UIView {
    private static let horizontalMargins = 16.0
    private static let verticalMargins = 8.0

    private let label = UILabel().makeView()
    private let divider = UIView().makeView()

    private lazy var visibleLabelConstraints: [NSLayoutConstraint] = [
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.horizontalMargins),
        label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Self.horizontalMargins),
        label.topAnchor.constraint(equalTo: topAnchor, constant: Self.verticalMargins),
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.verticalMargins)
    ]

    private lazy var visibleDividerConstraints: [NSLayoutConstraint] = [
        divider.heightAnchor.constraint(equalToConstant: 1),
        divider.topAnchor.constraint(equalTo: topAnchor, constant: -1),
        divider.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor),
        divider.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    ]

    private lazy var invisibleConstraints = [
        self.heightAnchor.constraint(equalToConstant: 0)
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
        addSubview(divider)
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
            NSLayoutConstraint.deactivate(visibleLabelConstraints)
            NSLayoutConstraint.deactivate(visibleDividerConstraints)
            NSLayoutConstraint.activate(invisibleConstraints)
        } else {
            NSLayoutConstraint.deactivate(invisibleConstraints)
            NSLayoutConstraint.activate(visibleLabelConstraints)
            NSLayoutConstraint.activate(visibleDividerConstraints)
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
        isHidden = props.isHidden
        divider.backgroundColor = props.style.dividerColor
        setFontScalingEnabled(props.style.accessibility.isFontScalingEnabled, for: label)
    }
}

extension SecureMessagingBottomBannerView {
    struct Props: Equatable {
        let style: SecureMessagingBottomBannerViewStyle
        let isHidden: Bool
    }
}

extension SecureMessagingBottomBannerView.Props {
    fileprivate static let initial = Self(style: .initial, isHidden: false)
}
