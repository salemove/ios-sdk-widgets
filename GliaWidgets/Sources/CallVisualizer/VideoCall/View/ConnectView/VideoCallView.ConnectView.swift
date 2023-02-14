import UIKit

extension CallVisualizer.VideoCallView {
    final class ConnectView: BaseView {

        // MARK: - Properties

        let operatorView = ConnectOperatorView()
        let statusView = ConnectStatusView()
        private var contentTopPadding: NSLayoutConstraint?

        static var contentInsets: UIEdgeInsets {
            .init(
                top: 6,
                left: 0,
                bottom: 10,
                right: 0
            )
        }

        var props: Props = Props() {
            didSet {
                renderProps()
            }
        }

        var renderShowing: CallVisualizer.VideoCallViewModel.Transaition = .hide(animation: false) {
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
            $0.distribution = .fillProportionally
        }

        // MARK: - Overrides

        override func setup() {
            super.setup()
            accessibilityElements = [operatorView, statusView]
            addSubview(stackView)
            stackView.addArrangedSubviews([operatorView, statusView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
        }

        override func defineLayout() {
            super.defineLayout()
            contentTopPadding = stackView.autoPinEdgesToSuperviewEdges(with: CallVisualizer.VideoCallView.ConnectView.contentInsets).first
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

        init(
            operatorViewProps: CallVisualizer.VideoCallView.ConnectOperatorView.Props = .init(),
            statusViewProps: CallVisualizer.VideoCallView.ConnectStatusView.Props = .init(),
            state: CallVisualizer.VideoCallViewModel.State = .initial,
            transition: CallVisualizer.VideoCallViewModel.Transaition = .hide(animation: false)
        ) {
            self.operatorViewProps = operatorViewProps
            self.statusViewProps = statusViewProps
            self.state = state
            self.transition = transition
        }
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
        UIView.animate(
            withDuration: animated ? 0.5 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                self.transform = .identity
            },
            completion: nil
        )
    }

    func hide(animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.5 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0, y: 0)
            },
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
