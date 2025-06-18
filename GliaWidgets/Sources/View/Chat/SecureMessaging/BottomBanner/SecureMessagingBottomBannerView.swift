import UIKit

final class SecureMessagingBottomBannerView: UIView {
    private static let horizontalMargins = 16.0
    private static let verticalMargins = 8.0

    private let label = UILabel()
    private let divider = UIView()

    private var visibleLabelConstraints: [NSLayoutConstraint] = []
    private var visibleDividerConstraints: [NSLayoutConstraint] = []
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
        divider.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        addSubview(divider)

        visibleLabelConstraints = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.horizontalMargins),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Self.horizontalMargins),
            label.topAnchor.constraint(equalTo: topAnchor, constant: Self.verticalMargins),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.verticalMargins)
        ]
        visibleDividerConstraints = [
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            divider.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor),
            divider.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ]

        NSLayoutConstraint.activate(visibleLabelConstraints)
        NSLayoutConstraint.activate(visibleDividerConstraints)

        zeroHeightConstraint = heightAnchor.constraint(equalToConstant: 0)
        zeroHeightConstraint.isActive = false

        renderProps()
    }

    private func renderProps() {
        label.text = props.style.message
        label.textColor = props.style.textColor
        backgroundColor = props.style.backgroundColor.color
        label.font = props.style.font
        divider.backgroundColor = props.style.dividerColor
        setFontScalingEnabled(props.style.accessibility.isFontScalingEnabled, for: label)

        if props.isHidden {
            label.isHidden = true
            divider.isHidden = true
            NSLayoutConstraint.deactivate(visibleLabelConstraints)
            NSLayoutConstraint.deactivate(visibleDividerConstraints)
            zeroHeightConstraint.isActive = true
        } else {
            zeroHeightConstraint.isActive = false
            NSLayoutConstraint.activate(visibleLabelConstraints)
            NSLayoutConstraint.activate(visibleDividerConstraints)
            label.isHidden = false
            divider.isHidden = false
        }
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
