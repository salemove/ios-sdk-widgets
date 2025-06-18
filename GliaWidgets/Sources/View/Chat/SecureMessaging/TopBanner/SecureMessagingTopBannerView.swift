import UIKit
import Combine

final class SecureMessagingTopBannerView: UIView {
    private static let horizontalMargins = 16.0
    private static let verticalMargins = 13.0
    private static let buttonImageHorizontalPadding = 6.0
    private static let rotationDuration = 0.3
    private let environment: Environment
    private let label = UILabel()
    private let divider = UIView()
    private let stackView = UIStackView()
    private var cancelBag = CancelBag()
    private var zeroHeightConstraint: NSLayoutConstraint!
    private var visibleStackViewConstraints: [NSLayoutConstraint] = []
    private var visibleDividerConstraints: [NSLayoutConstraint] = []

    @Published private var isExpanded = false

    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
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
        return button
    }()

    var props = Props.initial {
        didSet {
            guard props != oldValue else {
                return
            }
            renderProps()
        }
    }

    init(
        isExpanded: Published<Bool>.Publisher,
        environment: Environment
    ) {
        self.environment = environment
        super.init(frame: .zero)

        isExpanded.assign(to: &self.$isExpanded)

        $isExpanded
            .receive(on: environment.combineScheduler.main)
            .sink { [weak self] isExpanded in
                guard let self = self else { return }
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
        label.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        stackView.addArrangedSubviews([label, spacer, button])
        addSubview(divider)

        visibleStackViewConstraints = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.horizontalMargins),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.horizontalMargins),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Self.verticalMargins),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.verticalMargins)
        ]

        visibleDividerConstraints = [
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            divider.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor),
            divider.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ]

        NSLayoutConstraint.activate(visibleStackViewConstraints)
        NSLayoutConstraint.activate(visibleDividerConstraints)

        zeroHeightConstraint = heightAnchor.constraint(equalToConstant: 0)
        zeroHeightConstraint.isActive = false

        renderProps()
        setFontScalingEnabled(props.style.accessibility.isFontScalingEnabled, for: label)
    }

    func renderProps() {
        label.text = props.style.message
        label.textColor = props.style.textColor
        label.font = props.style.font
        backgroundColor = props.style.backgroundColor.color
        divider.backgroundColor = props.style.dividerColor
        button.setImage(props.style.buttonImage, for: .normal)
        button.tintColor = props.style.buttonImageColor

        if props.isHidden {
            stackView.isHidden = true
            divider.isHidden = true
            NSLayoutConstraint.deactivate(visibleStackViewConstraints)
            NSLayoutConstraint.deactivate(visibleDividerConstraints)
            zeroHeightConstraint.isActive = true
        } else {
            zeroHeightConstraint.isActive = false
            NSLayoutConstraint.activate(visibleStackViewConstraints)
            NSLayoutConstraint.activate(visibleDividerConstraints)
            stackView.isHidden = false
            divider.isHidden = false
        }
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
