import UIKit

final class SecureMessagingBottomBannerView: UIView {
    private static let horizontalMargins = 16.0
    private static let verticalMargins = 8.0

    private let label = UILabel().makeView()
    private let divider = UIView().makeView()

    private lazy var labelConstraints: [NSLayoutConstraint] = [
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.horizontalMargins),
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.horizontalMargins),
        label.topAnchor.constraint(equalTo: topAnchor, constant: Self.verticalMargins),
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.verticalMargins)
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
        renderHidden(isHidden)
        renderProps()
        addSubview(divider)
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
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
        // we deactivate label constraints if view gets hidden.
        if hidden {
            NSLayoutConstraint.deactivate(labelConstraints)
        } else {
            NSLayoutConstraint.activate(labelConstraints)
        }
        // Layout manually to enforce constraints to be applied immediately,
        // thus affecting the `frame`.
        layoutIfNeeded()
    }

    private func renderProps() {
        label.text = props.style.message
        label.textColor = props.style.textColor
        backgroundColor = props.style.backgroundColor
        label.font = props.style.font
        isHidden = props.isHidden
        divider.backgroundColor = props.style.dividerColor
    }

    override var intrinsicContentSize: CGSize {
        // When view is hidden, we should report zero height, to ensure that
        // it does not affect existing layout, by avoiding introduction of unnecessary
        // vertical gap, while keeping the view in hierarchy.
        isHidden ? .init(width: label.intrinsicContentSize.width, height: 0)
                 : label.intrinsicContentSize
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
