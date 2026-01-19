import SwiftUI

final class CallConnectViewHost: UIView {
    private let model: Model
    private let hostingController: UIHostingController<CallConnectView>

    init(
        connectStyle: ConnectStyle,
        callStyle: CallStyle,
        durationHint: String?,
        imageCache: ImageView.Cache
    ) {
        self.model = Model(
            connectStyle: connectStyle,
            callStyle: callStyle,
            durationHint: durationHint,
            imageCache: .from(imageCache)
        )
        let root = CallConnectView(model: self.model)
        self.hostingController = UIHostingController(rootView: root)
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        hostingController.view.isOpaque = false
    }

    private func layout() {
        addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(hostingController.view.layoutInSuperview())
    }

    func setState(_ state: EngagementState, durationText: String?) {
        model.state = state
        model.durationText = durationText
    }

    func setMode(_ mode: CallView.Mode) {
        model.mode = mode
    }
}
