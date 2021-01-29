import UIKit

class CallButton: UIView {
    enum Kind {
        case chat
        case video
        case mute
        case speaker
        case minimize
    }

    enum State {
        case active
        case inactive
    }

    var kind: Kind
    var state: State = .inactive {
        didSet { update(for: state) }
    }
    var isEnabled: Bool = true {
        didSet { setIsEnabled(isEnabled) }
    }
    var tap: (() -> Void)?

    private let style: CallButtonStyle
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let circleView = UIView()
    private let kCircleSize: CGFloat = 60

    public init(kind: Kind, style: CallButtonStyle) {
        self.kind = kind
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        circleView.clipsToBounds = true
        circleView.layer.cornerRadius = kCircleSize / 2.0

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        update(for: state)

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)
    }

    private func layout() {
        addSubview(circleView)
        circleView.autoSetDimensions(to: CGSize(width: kCircleSize, height: kCircleSize))
        circleView.autoPinEdge(toSuperviewEdge: .top)
        circleView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        circleView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        circleView.autoAlignAxis(toSuperviewAxis: .vertical)

        circleView.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()

        addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: circleView)
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        titleLabel.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func update(for state: State) {
        let style = self.style(for: state)
        circleView.backgroundColor = style.backgroundColor
        imageView.image = style.image
        imageView.tintColor = style.imageColor
        titleLabel.text = style.title
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
    }

    private func setIsEnabled(_ isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled
        alpha = isEnabled ? 1.0 : 0.4
    }

    private func style(for state: State) -> CallButtonStyle.StateStyle {
        switch state {
        case .active:
            return style.active
        case .inactive:
            return style.inactive
        }
    }

    @objc private func tapped() {
        tap?()
    }
}
