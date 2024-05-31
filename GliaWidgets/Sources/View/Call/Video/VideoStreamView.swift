import UIKit

class VideoStreamView: UIView {
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

    let flipButton = FlipCameraButton()

    var flipCameraButtonTapped: Cmd? {
        didSet {
            guard flipCameraButtonTapped != oldValue else {
                return
            }
            renderFlipCameraButton()
        }
    }

    private let kind: Kind

    init(_ kind: Kind) {
        self.kind = kind

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
        flipButton.props = FlipCameraButton.Props(
            // Relevant style will be provided with MOB-3292.
            style: .custom,
            tap: flipCameraButtonTapped
        )
    }
}
