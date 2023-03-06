import UIKit

extension CallVisualizer.VideoCallView {
    final class CallButtonBar: BaseView {

        // MARK: - Properties

        var props: Props {
            didSet {
                renderProps()
            }
        }

        private var renderEffect: Header.Effect = .none {
            didSet {
                guard renderEffect != oldValue else { return }
                switch renderEffect {
                case .none:
                    effectView.isHidden = true
                case .blur:
                    effectView.isHidden = false
                }
            }
        }

        private let stackView = UIStackView()
        private let insets = UIEdgeInsets(top: 7.0, left: 3.0, bottom: 7.0, right: 3.0)
        private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        private var bottomSpaceConstraint: NSLayoutConstraint?
        private var leftConstraint: NSLayoutConstraint?
        private var rightConstraint: NSLayoutConstraint?
        private var verticalAlignConstrait: NSLayoutConstraint?
        private let videoButton: CallButton
        private let minimizeButton: CallButton

        // MARK: - Initializer

        init(props: Props) {
            self.props = props
            videoButton = .init(kind: .video, style: props.style.videoButton)
            minimizeButton = .init(kind: .minimize, style: props.style.minimizeButton)
            effectView.isHidden = true
            super.init()
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        // MARK: - Overrides

        override func layoutSubviews() {
            super.layoutSubviews()
            adjustBottomSpacing()
            adjustStackConstraints()
        }

        override func defineLayout() {
            super.defineLayout()
            adjustStackConstraints()
            addSubview(effectView)
            effectView.autoPinEdgesToSuperviewEdges()

            addSubview(stackView)
            stackView.autoPinEdge(toSuperviewEdge: .top, withInset: insets.top)
            leftConstraint = stackView.autoPinEdge(toSuperviewEdge: .left, withInset: insets.left)
            rightConstraint = stackView.autoPinEdge(toSuperviewEdge: .right, withInset: insets.right)
            verticalAlignConstrait = stackView.autoAlignAxis(toSuperviewAxis: .vertical)
            bottomSpaceConstraint = stackView.autoPinEdge(toSuperviewEdge: .bottom)
        }

        override func setup() {
            super.setup()
            minimizeButton.state = .inactive
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually

            stackView.removeArrangedSubviews()
            videoButton.tap = { [weak self] in
                self?.props.videoButtonTap()
            }
            minimizeButton.tap = { [weak self] in
                self?.props.minimizeTap()
            }

            let allButtons = [
                videoButton,
                minimizeButton
            ]

            allButtons.forEach {
                let wrapper = wrap($0)
                stackView.addArrangedSubview(wrapper)
            }
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallView.CallButtonBar {
    struct Props: Equatable {
        let style: CallButtonBarStyle
        let videoButtonTap: Cmd
        let minimizeTap: Cmd
        let videoButtonState: CallButton.State
        let videoButtonEnabled: Bool
        let minimzeButtonEnabled: Bool
        let effect: Header.Effect

        init(
            style: CallButtonBarStyle,
            videoButtonTap: Cmd,
            minimizeTap: Cmd,
            videoButtonState: CallButton.State = .active,
            videoButtonEnabled: Bool = true,
            minimizeButtonEnabled: Bool = true,
            effect: Header.Effect = .none
        ) {
            self.style = style
            self.videoButtonTap = videoButtonTap
            self.minimizeTap = minimizeTap
            self.videoButtonState = videoButtonState
            self.videoButtonEnabled = videoButtonEnabled
            self.minimzeButtonEnabled = minimizeButtonEnabled
            self.effect = effect
        }
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallView.CallButtonBar {
    func renderProps() {
        videoButton.state = props.videoButtonState
        videoButton.isEnabled = props.videoButtonEnabled
        minimizeButton.isEnabled = props.minimzeButtonEnabled
        renderEffect = props.effect
        adjustStackConstraints()
    }

    func adjustBottomSpacing() {
        bottomSpaceConstraint?.constant = -(safeAreaInsets.bottom + insets.bottom)
    }

    func wrap(_ button: CallButton) -> UIView {
        let wrapper = UIView()
        wrapper.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .top)
        button.autoPinEdge(toSuperviewEdge: .bottom)
        button.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        button.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        button.autoAlignAxis(toSuperviewAxis: .vertical)
        return wrapper
    }

    func adjustStackConstraints() {
        if currentOrientation.isPortrait {
            verticalAlignConstrait?.autoRemove()
            stackView.spacing = 0
            leftConstraint?.autoInstall()
            rightConstraint?.autoInstall()
            renderEffect = .none
        } else {
            leftConstraint?.autoRemove()
            rightConstraint?.autoRemove()
            stackView.spacing = 84
            verticalAlignConstrait?.autoInstall()
            renderEffect = .blur
        }
    }
}
