import SwiftUI

final class ChatConnectViewHost: UIView {
    private let model: Model
    private let hostingController: UIHostingController<ChatConnectView>

    init(
        connectStyle: ConnectStyle,
        imageCache: ImageView.Cache
    ) {
        self.model = Model(
            connectStyle: connectStyle,
            imageCache: .from(imageCache)
        )
        let root = ChatConnectView(model: model)
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
        isAccessibilityElement = false
    }

    private func layout() {
        addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(hostingController.view.layoutInSuperview())
    }

    func setState(_ state: EngagementState) {
        model.state = state
    }
}
