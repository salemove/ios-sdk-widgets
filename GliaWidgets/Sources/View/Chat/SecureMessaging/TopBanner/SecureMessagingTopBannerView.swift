import UIKit
import Combine

final class SecureMessagingTopBannerView: UIView {
    private static let horizontalMargins = 16.0
    private static let verticalMargins = 13.0
    private static let buttonImageHorizontalPadding = 6.0
    private static let rotationDuration = 0.3

    private let label = UILabel().makeView { label in
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    private let divider = UIView().makeView()
    private let stackView = UIStackView().makeView { view in
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 8
    }
    private lazy var button = UIButton(type: .custom).makeView { button in
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)

        if #available(iOS 15, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = .init(
                top: 0,
                leading: Self.buttonImageHorizontalPadding,
                bottom: 0,
                trailing: Self.buttonImageHorizontalPadding
            )
            button.configuration = configuration
        } else {
            button.imageEdgeInsets = .init(
                top: 0,
                left: Self.buttonImageHorizontalPadding,
                bottom: 0,
                right: Self.buttonImageHorizontalPadding
            )
        }
    }

    @Published private var isExpanded = false

    private var cancelBag = CancelBag()

    private lazy var visibleStackViewConstraints: [NSLayoutConstraint] = [
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.horizontalMargins),
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.horizontalMargins),
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: Self.verticalMargins),
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.verticalMargins)
    ]

    private lazy var visibleDividerConstraints: [NSLayoutConstraint] = [
        divider.heightAnchor.constraint(equalToConstant: 1),
        divider.topAnchor.constraint(equalTo: bottomAnchor, constant: 0),
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

    override var isHidden: Bool {
        didSet {
            super.isHidden = self.isHidden
            guard isHidden != oldValue else {
                return
            }
            renderHidden(self.isHidden)
        }
    }

    init(isExpanded: Published<Bool>.Publisher) {
        super.init(frame: .zero)

        isExpanded.assign(to: &self.$isExpanded)

        $isExpanded
            // injected combine scheduler will be added here in MOB-4077
            .receive(on: DispatchQueue.main)
            .sink { isExpanded in
                let angle = isExpanded ? .pi : 0
                UIView.animate(withDuration: Self.rotationDuration) {
                    self.button.imageView?.transform = CGAffineTransform(rotationAngle: angle)
                }
            }
            .store(in: &cancelBag)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension SecureMessagingTopBannerView {
    func setup() {
        addSubview(stackView)
        label.numberOfLines = 0

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        stackView.addArrangedSubviews([label, spacer, button])
        addSubview(divider)
        renderHidden(isHidden)
        renderProps()
        setFontScalingEnabled(props.style.accessibility.isFontScalingEnabled, for: label)
    }

    func renderHidden(_ hidden: Bool) {
        // In order to avoid breaking auto-layout constraints
        // we deactivate relevant constraints if view gets hidden
        // and activate zero-height constraints.
        if hidden {
            NSLayoutConstraint.deactivate(visibleStackViewConstraints)
            NSLayoutConstraint.deactivate(visibleDividerConstraints)
            NSLayoutConstraint.activate(invisibleConstraints)
        } else {
            NSLayoutConstraint.deactivate(invisibleConstraints)
            NSLayoutConstraint.activate(visibleStackViewConstraints)
            NSLayoutConstraint.activate(visibleDividerConstraints)
        }
        // Layout manually to enforce constraints to be applied immediately,
        // thus affecting the `frame`.
        layoutIfNeeded()
    }

    func renderProps() {
        label.text = props.style.message
        label.textColor = props.style.textColor
        label.font = props.style.font
        backgroundColor = props.style.backgroundColor.color
        isHidden = props.isHidden

        divider.backgroundColor = props.style.dividerColor

        button.setImage(props.style.buttonImage, for: .normal)
        button.tintColor = props.style.buttonImageColor
    }

    @objc func buttonTap() {
        isExpanded.toggle()
        props.buttonTap(isExpanded)
    }
}

extension SecureMessagingTopBannerView {
    struct Props: Equatable {
        let style: SecureMessagingTopBannerViewStyle
        let buttonTap: Command<Bool>
        let isHidden: Bool
    }
}

extension SecureMessagingTopBannerView.Props {
    fileprivate static let initial = Self(style: .initial, buttonTap: .nop, isHidden: false)
}
