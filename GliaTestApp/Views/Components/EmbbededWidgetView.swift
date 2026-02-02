import SwiftUI

struct EmbeddedWidgetView: UIViewRepresentable {
    let onViewReady: (UIView) -> Void

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true

        DispatchQueue.main.async {
            onViewReady(containerView)
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
