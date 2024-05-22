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
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            addSubview(effectView)
            effectView.translatesAutoresizingMaskIntoConstraints = false
            constraints += effectView.layoutInSuperview()

            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            constraints += stackView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top)
            leftConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left)
            rightConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
            verticalAlignConstrait = stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
            bottomSpaceConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            constraints += [leftConstraint, rightConstraint, verticalAlignConstrait, bottomSpaceConstraint].compactMap { $0 }
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

            allButtons.forEach { button in
                var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
                let wrapper = UIView()
                wrapper.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                constraints += button.layoutInSuperview(edges: .vertical)
                constraints += button.leadingAnchor.constraint(greaterThanOrEqualTo: wrapper.leadingAnchor)
                constraints += button.trailingAnchor.constraint(lessThanOrEqualTo: wrapper.trailingAnchor)
                constraints += button.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor)

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

    func adjustStackConstraints() {
        if currentOrientation.isPortrait {
            stackView.spacing = 0
            renderEffect = .none
        } else {
            stackView.spacing = 84
            renderEffect = .blur
        }
    }
}
