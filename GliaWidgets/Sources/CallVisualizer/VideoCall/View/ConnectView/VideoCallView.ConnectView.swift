import UIKit

extension CallVisualizer.VideoCallView {
    final class ConnectView: BaseView {
        // MARK: - Properties

        private let operatorView: ConnectOperatorView
        private let statusView = ConnectStatusView()
        private var contentTopPadding: NSLayoutConstraint?

        static var contentInsets: UIEdgeInsets {
            .init(
                top: 6,
                left: 0,
                bottom: 10,
                right: 0
            )
        }

        var props: Props {
            didSet {
                renderProps()
            }
        }

        private var renderShowing: CallVisualizer.VideoCallViewModel.Transaition = .hide(animation: false) {
            didSet {
                guard renderShowing != oldValue else { return }
                switch renderShowing {
                case let .show(animation):
                    show(animated: animation)
                case let .hide(animation):
                    hide(animated: animation)
                }
            }
        }

        private lazy var stackView = UIStackView().make {
            $0.axis = .vertical
            $0.spacing = 1
        }

        // MARK: - Initializer

        init(props: Props) {
            self.props = props
            self.operatorView = .init(props: props.operatorViewProps)
            super.init()
        }

        @available(*, unavailable)
        required init() {
            fatalError("init() has not been implemented")
        }

        // MARK: - Overrides

        override func setup() {
            super.setup()
            accessibilityElements = [operatorView, statusView]

            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubviews([operatorView, statusView])
            operatorView.translatesAutoresizingMaskIntoConstraints = false
        }

        override func defineLayout() {
            super.defineLayout()
            let insets = CallVisualizer.VideoCallView.ConnectView.contentInsets
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            let topConstraint = stackView.topAnchor.constraint(
                equalTo: topAnchor, constant: insets.top
            )
            constraints += topConstraint
            contentTopPadding = topConstraint
            constraints += stackView.layoutInSuperview(
                edges: .horizontal,
                insets: insets
            )
            constraints += stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
            constraints += operatorView.heightAnchor.constraint(equalToConstant: 142)
        }
    }
}

// MARK: - Props
extension CallVisualizer.VideoCallView.ConnectView {
    struct Props: Equatable {
        let operatorViewProps: CallVisualizer.VideoCallView.ConnectOperatorView.Props
        let statusViewProps: CallVisualizer.VideoCallView.ConnectStatusView.Props
        let state: CallVisualizer.VideoCallViewModel.State
        let transition: CallVisualizer.VideoCallViewModel.Transaition
    }
}

extension CallVisualizer.VideoCallView.ConnectView.Props {
    enum Layout {
        case chat, call
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallView.ConnectView {
    func renderProps() {
        operatorView.props = props.operatorViewProps
        statusView.props = props.statusViewProps
        contentSpacing(for: props.state)
        topPadding(for: props.state)
        renderShowing = props.transition
        updateConstraints()
    }

    func show(animated: Bool) {
        animate(animated: animated) {
            self.transform = .identity
        }
    }

    func hide(animated: Bool) {
        animate(animated: animated) {
            self.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
    }

    func animate(
        animated: Bool,
        animations: @escaping () -> Void
    ) {
        UIView.animate(
            withDuration: animated ? 0.5 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: animations,
            completion: nil
        )
    }

    func contentSpacing(for state: CallVisualizer.VideoCallViewModel.State) {
        switch state {
        case .initial, .queue, .connecting, .transferring:
            stackView.spacing = 1
        case .connected:
            stackView.spacing = 18
        }
    }

    func topPadding(for state: CallVisualizer.VideoCallViewModel.State) {
        switch state {
        case .initial, .queue, .connecting, .transferring:
            contentTopPadding?.constant = 32
        case .connected:
            contentTopPadding?.constant = 14
        }
    }
}
