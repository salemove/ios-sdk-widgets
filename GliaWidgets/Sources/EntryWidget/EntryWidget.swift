import Combine
import Foundation
import GliaCoreSDK
import UIKit
import SwiftUI

public final class EntryWidget: NSObject {
    private var hostedViewController: UIViewController?
    private var embeddedView: UIView?
    private var queueIds: [String] = []

    @Published private var channels: [Channel] = []
    private let sizeConstraints: SizeConstraints = .init(
        singleCellHeight: 72,
        singleCellIconSize: 24,
        poweredByContainerHeight: 40,
        sheetHeaderHeight: 36,
        sheetHeaderDraggerWidth: 32,
        sheetHeaderDraggerHeight: 4,
        dividerHeight: 1
    )

    private let environment: Environment

    private var cancellables = CancelBag()

    init(environment: Environment) {
        self.environment = environment
        super.init()

        environment.queuesMonitor.$state
            .sink(receiveValue: handleQueuesMonitorUpdates(state:))
            .store(in: &cancellables)
    }

    public func show(by presentation: EntryWidget.Presentation) {
        defer {
            environment.queuesMonitor.startMonitoring(queuesIds: queueIds)
        }
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

        environment.queuesMonitor.stopMonitoring()
    }
}

private extension EntryWidget {
    func showView(in parentView: UIView) {
        parentView.subviews.forEach { $0.removeFromSuperview() }
        let model = makeViewModel(
            showHeader: false,
            channels: channels,
            selection: channelSelected(_:)
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
            selection: channelSelected(_:)
        )
        let view = makeView(model: model)
        let hostingController = UIHostingController(rootView: view)

        switch environment.theme.entryWidget.backgroundColor {
        case .fill(let color):
            hostingController.view.backgroundColor = color
        case .gradient(let colors):
            hostingController.view.makeGradientBackground(
                colors: colors,
                cornerRadius: environment.theme.entryWidget.cornerRadius
            )
        }

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
            sheet.preferredCornerRadius = environment.theme.entryWidget.cornerRadius
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
        selection: @escaping (Channel) throws -> Void
    ) -> EntryWidgetView.Model {
        .init(
            theme: environment.theme,
            showHeader: showHeader,
            sizeConstrainsts: sizeConstraints,
            channels: $channels,
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
            height: height,
            cornerRadius: environment.theme.entryWidget.cornerRadius
        )
    }
}

private extension EntryWidget {
    func handleQueuesMonitorUpdates(state: QueuesMonitor.State) {
        switch state {
        case .idle:
            break
        case .updated(let queues):
            let availableChannels = resolveAvailableChannels(from: queues)
            self.channels = availableChannels
        case .failed(let error):
            // TODO: Handle error on EntryWidgetView
            print(error)
        }
    }

    func resolveAvailableChannels(from queues: [Queue]) -> [Channel] {
        var availableChannels: Set<Channel> = []

        queues.forEach { queue in
            queue.state.media.forEach { mediaType in
                guard let channel = Channel(mediaType: mediaType) else {
                    return
                }
                availableChannels.insert(channel)
            }
        }
        // TODO: Add sorting for representing on UI
        return Array(availableChannels)
    }

    func channelSelected(_ channel: Channel) throws {
        switch channel {
        case .chat:
            try environment.engagementLauncher.startChat()
        case .audio:
            try environment.engagementLauncher.startAudioCall()
        case .video:
            try environment.engagementLauncher.startVideoCall()
        case .secureMessaging:
            try environment.engagementLauncher.startSecureMessaging()
        }
    }
}
