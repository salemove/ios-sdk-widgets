import Foundation
import UIKit
import SwiftUI

public final class EntryWidget: NSObject {
    private var hostedViewController: UIViewController?
    private var embeddedView: UIView?
    private var queueIds: [String] = []

    // Channels will become dynamic in the subsequent PRs
    private var channels: [Channel] = [.chat, .audio, .video, .secureMessaging]
    private let theme: Theme
    private let sizeConstraints: SizeConstraints = .init(
        singleCellHeight: 72,
        singleCellIconSize: 24,
        poweredByContainerHeight: 40,
        sheetHeaderHeight: 36,
        sheetHeaderDraggerWidth: 32,
        sheetHeaderDraggerHeight: 4,
        dividerHeight: 1
    )

    init(theme: Theme) {
        self.theme = theme
    }

    public func show(by presentation: EntryWidget.Presentation) {
        switch presentation {
        case let .sheet(parentViewController):
            showSheet(in: parentViewController)
        case let .embedded(parentView):
            showView(in: parentView)
        }
    }

    func hide() {
        hostedViewController?.dismiss(animated: true, completion: nil)
        hostedViewController = nil
        embeddedView?.removeFromSuperview()
        embeddedView = nil
    }

    func createEntryWidgetView(
        queueIds: [String],
        channels: [Channel] = [.chat, .audio, .video]
    ) {
        self.queueIds = queueIds
        self.channels = channels
    }
}

private extension EntryWidget {
    func showView(in parentView: UIView) {
        parentView.subviews.forEach { $0.removeFromSuperview() }
        let model = makeViewModel(
            showHeader: false,
            channels: channels,
            selection: { channel in
                // Logic for handling this callback will be handled later - MOB-3473
                print(channel.headline)
            }
        )
        let view = makeView(model: model)
        let hostingController = UIHostingController(rootView: view)

        parentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.widthAnchor.constraint(equalTo: parentView.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: parentView.heightAnchor),
            hostingController.view.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])

        embeddedView = hostingController.view
    }

    func showSheet(in parentViewController: UIViewController) {
        let model = makeViewModel(
            showHeader: true,
            channels: channels,
            selection: { channel in
                // Logic for handling this callback will be handled later - MOB-3473
                print(channel.headline)
            }
        )
        let view = makeView(model: model)
        let hostingController = UIHostingController(rootView: view)

        hostingController.view.backgroundColor = UIColor.white

        // Due to the more modern sheet presenting approach being
        // available starting from iOS 16, we need to handle cases
        // where the visitor has either iOS 14 or 15 installed. For
        // such visitors, we fall back on CustomPresentationController
        //
        if #available(iOS 16.0, *) {
            guard let sheet = hostingController.sheetPresentationController else { return }
            let smallDetent: UISheetPresentationController.Detent = .custom { _ in
                return self.calculateHeight(
                    channels: self.channels,
                    sizeConstraints: self.sizeConstraints
                )
            }
            sheet.detents = [smallDetent]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 24
        } else {
            hostingController.modalPresentationStyle = .custom
            hostingController.transitioningDelegate = self
        }

        parentViewController.present(hostingController, animated: true, completion: nil)
        hostedViewController = hostingController
    }

    func makeView(model: EntryWidgetView.Model) -> EntryWidgetView {
        .init(model: model)
    }

    func makeViewModel(
        showHeader: Bool,
        channels: [Channel],
        selection: @escaping (Channel) -> Void
    ) -> EntryWidgetView.Model {
        .init(
            theme: theme,
            showHeader: showHeader,
            sizeConstrainsts: sizeConstraints,
            channels: channels,
            channelSelected: selection
        )
    }

    func calculateHeight(
        channels: [Channel],
        sizeConstraints: SizeConstraints
    ) -> CGFloat {
        var appliedHeight: CGFloat = 0

        appliedHeight += sizeConstraints.sheetHeaderHeight
        channels.forEach { _ in
            appliedHeight += sizeConstraints.singleCellHeight
            appliedHeight += sizeConstraints.dividerHeight
        }
        appliedHeight += sizeConstraints.poweredByContainerHeight

        return appliedHeight
    }
}

extension EntryWidget: UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let height = calculateHeight(
            channels: channels,
            sizeConstraints: sizeConstraints
        )
        return CustomPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            height: height
        )
    }
}
