import UIKit

final class ConnectView: BaseView {
    private enum Constants {
        static var contentInsets: UIEdgeInsets {
            .init(
                top: State.initial.chatTopPadding,
                left: 0,
                bottom: 10,
                right: 0
            )
        }
    }

    enum Layout {
        case chat, call
    }

    enum State: Equatable {
        case initial
        case queue
        case connecting(name: String?, imageUrl: String?)
        case connected(name: String?, imageUrl: String?)
        case transferring
    }

    let operatorView: ConnectOperatorView
    let statusView = ConnectStatusView()

    private let layout: Layout
    private let style: ConnectStyle
    private var state: State = .initial
    private var connectTimer: FoundationBased.Timer?
    private var connectCounter: Int = 0
    private var isShowing = false
    private let environment: Environment
    private lazy var stackView = UIStackView.make(
        .vertical,
        spacing: State.initial.chatContentSpacing,
        distribution: .fillProportionally
    )(
        operatorView,
        statusView
    )
    private var contentTopPadding: NSLayoutConstraint?

    init(
        with style: ConnectStyle,
        layout: Layout,
        environment: Environment
    ) {
        self.style = style
        self.layout = layout
        self.environment = environment
        self.operatorView = ConnectOperatorView(
            with: style.connectOperator,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func setup() {
        super.setup()
        accessibilityElements = [operatorView, statusView]

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        setState(.initial, animated: false)
    }

    override func defineLayout() {
        super.defineLayout()
        // `autoPinEdgesToSuperviewEdges` returns array of constraints where first one is for top padding.
        contentTopPadding = stackView.autoPinEdgesToSuperviewEdges(with: Constants.contentInsets).first
    }

    func setState(_ state: State, animated: Bool) {
        self.state = state
        stackView.spacing = layout.contentSpacing(for: state)
        contentTopPadding?.constant = layout.topPadding(for: state)
        updateConstraints()

        switch state {
        case .initial:
            stopConnectTimer()
            hide(animated: animated)
        case .queue:
            stopConnectTimer()
            operatorView.imageView.setPlaceholderImage(style.connectOperator.operatorImage.placeholderImage)
            operatorView.startAnimating(animated: animated)
            statusView.setFirstText(style.queue.firstText, animated: false)
            statusView.setSecondText(style.queue.secondText, animated: false)
            statusView.setStyle(style.queue)
            show(animated: animated)
        case .connecting(let name, let imageUrl):
            operatorView.startAnimating(animated: animated)
            operatorView.imageView.setPlaceholderImage(style.connectOperator.operatorImage.placeholderImage)
            operatorView.imageView.setOperatorImage(fromUrl: imageUrl, animated: true)
            let firstText = style.connecting.firstText?.withOperatorName(name)
            statusView.setFirstText(firstText, animated: animated)
            statusView.setSecondText(nil, animated: animated)
            statusView.setStyle(style.connecting)
            startConnectTimer()
            show(animated: animated)
        case .connected(let name, let imageUrl):
            stopConnectTimer()
            operatorView.stopAnimating(animated: animated)
            operatorView.imageView.setPlaceholderImage(style.connectOperator.operatorImage.placeholderImage)
            operatorView.imageView.setOperatorImage(fromUrl: imageUrl, animated: true)
            if let name = name {
                let firstText = style.connected.firstText?.withOperatorName(name)
                let secondText = style.connected.secondText?
                    .withOperatorName(name)
                    .withCallDuration("00:00")
                statusView.setFirstText(firstText, animated: animated)
                statusView.setSecondText(secondText, animated: animated)
            } else {
                statusView.setFirstText(nil, animated: animated)
                statusView.setSecondText(nil, animated: animated)
            }
            statusView.setStyle(style.connected)
            show(animated: animated)
        case .transferring:
            stopConnectTimer()
            operatorView.setSize(.normal, animated: true)
            operatorView.startAnimating(animated: animated)
            operatorView.imageView.setOperatorImage(nil, animated: true)
            operatorView.imageView.setPlaceholderImage(style.connectOperator.operatorImage.transferringImage)
            statusView.setFirstText(style.transferring.firstText, animated: true)
            statusView.setSecondText(style.transferring.secondText, animated: true)
            statusView.setStyle(style.transferring)
            show(animated: animated)
        }
    }

    private func show(animated: Bool) {
        guard !isShowing else { return }
        UIView.animate(
            withDuration: animated ? 0.5 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                self.transform = .identity
            }, completion: nil)
        isShowing = true
    }

    private func hide(animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.5 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0, y: 0)
            }, completion: nil)
        isShowing = false
    }
}

private extension ConnectView {
    private func startConnectTimer() {
        stopConnectTimer()
        connectCounter = 0
        connectTimer = environment.timerProviding.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            switch self.state {
            case .connecting:
                self.connectCounter += 1
                self.statusView.setSecondText("\(self.connectCounter)", animated: true)
            default:
                self.connectTimer?.invalidate()
                self.connectTimer = nil
            }
        }
    }

    private func stopConnectTimer() {
        connectTimer?.invalidate()
        connectTimer = nil
    }
}

extension ConnectView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var timerProviding: FoundationBased.Timer.Providing
    }
}

extension ConnectView.State {
    var chatContentSpacing: CGFloat {
        switch self {
        case .initial, .queue, .connecting, .transferring:
            return 0
        case .connected:
            return 12
        }
    }

    var callContentSpacing: CGFloat {
        switch self {
        case .initial, .queue, .connecting, .transferring:
            return 1
        case .connected:
            return 18
        }
    }

    var chatTopPadding: CGFloat {
        switch self {
        case .initial, .queue, .connecting, .transferring:
            return 6
        case .connected:
            return 14
        }
    }

    var callTopPadding: CGFloat {
        switch self {
        case .initial, .queue, .connecting, .transferring:
            return 0
        case .connected:
            return 14
        }
    }
}

extension ConnectView.Layout {
    func topPadding(for state: ConnectView.State) -> CGFloat {
        switch self {
        case .chat:
            return state.chatTopPadding
        case .call:
            return state.callTopPadding
        }
    }

    func contentSpacing(for state: ConnectView.State) -> CGFloat {
        switch self {
        case .chat:
            return state.chatContentSpacing
        case .call:
            return state.callContentSpacing
        }
    }
}
