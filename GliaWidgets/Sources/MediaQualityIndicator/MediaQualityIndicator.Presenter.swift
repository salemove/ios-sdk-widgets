import UIKit
import SwiftUI

protocol MediaQualityIndicatorHost: AnyObject {
    var mediaQualityIndicatorContainerView: UIView { get }
    var mediaQualityIndicatorTopAnchor: NSLayoutYAxisAnchor { get }
}

final class MediaQualityIndicatorPresenter {
    private weak var parentViewController: UIViewController?
    private weak var host: MediaQualityIndicatorHost?

    private let style: MediaQualityIndicatorStyle
    private let height: CGFloat

    private var hostingController: UIHostingController<MediaQualityIndicatorView>?
    private(set) var state: State = .hidden

    init(
        style: MediaQualityIndicatorStyle,
        parentViewController: UIViewController,
        host: MediaQualityIndicatorHost,
        height: CGFloat = 28
    ) {
        self.style = style
        self.parentViewController = parentViewController
        self.host = host
        self.height = height
    }
}

extension MediaQualityIndicatorPresenter {
    func show(animated: Bool = true) {
        guard state == .hidden else { return }
        guard let parentViewController else { return }
        guard let host else { return }

        let container = host.mediaQualityIndicatorContainerView

        let controller = UIHostingController(
            rootView: MediaQualityIndicatorView(style: style)
        )
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        parentViewController.addChild(controller)
        container.addSubview(controller.view)

        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: host.mediaQualityIndicatorTopAnchor),
            controller.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            controller.view.heightAnchor.constraint(equalToConstant: height)
        ])

        controller.didMove(toParent: parentViewController)
        hostingController = controller
        state = .shown

        if animated {
            controller.view.alpha = 0
            controller.view.transform = CGAffineTransform(scaleX: 1, y: 0.95)

            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
                controller.view.alpha = 1
                controller.view.transform = .identity
            }
        }
    }

    func hide(animated: Bool = true) {
        guard state == .shown,
              let controller = hostingController else { return }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
                controller.view.alpha = 0
                controller.view.transform = CGAffineTransform(scaleX: 1, y: 0.95)
            } completion: { [weak self] _ in
                self?.cleanup()
            }
        } else {
            cleanup()
        }
    }
}

private extension MediaQualityIndicatorPresenter {
    func cleanup() {
        guard let controller = hostingController else { return }
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        hostingController = nil
        state = .hidden
    }
}

extension MediaQualityIndicatorPresenter {
    enum State: Equatable {
        case hidden
        case shown
    }
}
