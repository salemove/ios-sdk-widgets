import UIKit

class VideoStreamView: UIView {
    typealias FlipCameraAccLabelWithTap = (accessibilityLabel: String, tapCallback: Cmd)

    enum Kind {
        case local
        case remote
    }

    let label = UILabel()
    var pan: ((CGPoint) -> Void)?
    var show: ((Bool) -> Void)?

    weak var streamView: CoreSdkClient.StreamView? {
        didSet {
            replace(oldStreamView: oldValue, with: streamView)
        }
    }

    private let flipButton = FlipCameraButton()

    var flipCameraAccessibilityLabelWithTap: FlipCameraAccLabelWithTap? {
        didSet {
            renderFlipCameraButton()
            renderLocalVideoAccessibility()
        }
    }

    private let kind: Kind
    private let flipCameraButtonStyle: FlipCameraButtonStyle

    init(
        _ kind: Kind,
        flipCameraButtonStyle: FlipCameraButtonStyle
    ) {
        self.kind = kind
        self.flipCameraButtonStyle = flipCameraButtonStyle

        super.init(frame: .zero)

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        clipsToBounds = true
        layer.cornerRadius = kind == .local ? 6.0 : 0.0

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        addGestureRecognizer(panRecognizer)

        isAccessibilityElement = true

        label.isHidden = true
    }

    private func replace(
        oldStreamView: CoreSdkClient.StreamView?,
        with streamView: CoreSdkClient.StreamView?
    ) {
        oldStreamView?.removeFromSuperview()
        label.removeFromSuperview()

        guard let streamView = streamView else {
            show?(false)
            return
        }
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        streamView.scale = kind == .remote ? .aspectFit : .aspectFill

        addSubview(streamView)
        streamView.translatesAutoresizingMaskIntoConstraints = false
        constraints += streamView.layoutInSuperview()
        streamView.layoutIfNeeded()

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        constraints += label.layoutInSuperviewCenter()
        show?(true)

        switch self.kind {
        case .local:
            addSubview(flipButton)
            flipButton.translatesAutoresizingMaskIntoConstraints = false
            constraints += [
                flipButton.widthAnchor.constraint(equalToConstant: FlipCameraButton.size.width),
                flipButton.heightAnchor.constraint(equalToConstant: FlipCameraButton.size.height),
                flipButton.bottomAnchor.constraint(
                    equalTo: self.bottomAnchor,
                    constant: FlipCameraButton.bottomTrailingPadding
                ),
                flipButton.trailingAnchor.constraint(
                    equalTo: self.trailingAnchor,
                    constant: FlipCameraButton.bottomTrailingPadding
                )
            ]
            renderFlipCameraButton()
            renderLocalVideoAccessibility()
        case .remote:
            break
        }
    }

    @objc
    private func pan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.view != nil else { return }

        let translation = gesture.translation(in: self)
        pan?(translation)
        gesture.setTranslation(.zero, in: self)
    }

    func renderFlipCameraButton() {
        let flipButtonStyle = self.flipCameraButtonStyle

        let props: FlipCameraButton.Props

        if let flipCameraAccessibilityLabelWithTap {
            props = .init(
                style: flipButtonStyle,
                tap: flipCameraAccessibilityLabelWithTap.tapCallback,
                accessibilityLabel: flipCameraAccessibilityLabelWithTap.accessibilityLabel
            )
        } else {
            props = .init(style: flipButtonStyle, tap: nil, accessibilityLabel: "")
        }

        flipButton.props = props
    }

    func renderLocalVideoAccessibility() {
        // We need to change accessibility behaviour
        // in case if flip camera button is present,
        // to allow it to be recognizable by screen reader.
        if flipCameraAccessibilityLabelWithTap != nil {
            // Parent container can not be accessibility element,
            // if child needs to be accessibility element as well,
            // but siblings within same containers can.
            self.isAccessibilityElement = false
            // So we make `streamView` (which is sibling to
            // flip camera button) an accessibility element.
            streamView?.isAccessibilityElement = true
            // Also we forward `accessibilityLabel` from parent to
            // `streamView`, so that it would be read instead.
            streamView?.accessibilityLabel = accessibilityLabel
            // Finally we assign `streamView` and `flipButton` to
            // accessibility elements group.
            self.accessibilityElements = [streamView].compactMap { $0 } + [self.flipButton]
        } else {
            self.isAccessibilityElement = true
            self.accessibilityElements = nil
        }
    }
}
