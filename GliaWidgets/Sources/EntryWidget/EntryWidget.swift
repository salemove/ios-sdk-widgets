import Combine
import Foundation
import GliaCoreSDK
import UIKit
import SwiftUI

public final class EntryWidget: NSObject {
    private var hostedViewController: UIViewController?
    private var embeddedView: UIView?
    private var queueIds: [String]

    @Published private var viewState: ViewState = .loading

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

    init(
        queueIds: [String],
        environment: Environment
    ) {
        self.queueIds = queueIds
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

// MARK: - Private methods
private extension EntryWidget {
    func handleQueuesMonitorUpdates(state: QueuesMonitor.State) {
        switch state {
        case .idle:
            viewState = .loading
        case .updated(let queues):
            let availableMediaTypes = resolveAvailableMediaTypes(from: queues)
            if availableMediaTypes.isEmpty {
                viewState = .offline
            } else {
                viewState = .mediaTypes(availableMediaTypes)
            }
        case .failed:
            viewState = .error
            print("Failed to update queues")
        }
    }

    func resolveAvailableMediaTypes(from queues: [Queue]) -> [MediaTypeItem] {
        var availableMediaTypes: Set<MediaTypeItem> = []

        queues.forEach { queue in
            queue.state.media.forEach { mediaType in
                if let mediaTypeItem = MediaTypeItem(mediaType: mediaType) {
                    availableMediaTypes.insert(mediaTypeItem)
                }
            }
        }
        return Array(availableMediaTypes).sorted(by: { $0.rawValue < $1.rawValue })
    }

    func mediaTypeSelected(_ mediaTypeItem: MediaTypeItem) {
        do {
            switch mediaTypeItem {
            case .chat:
                try environment.engagementLauncher.startChat()
            case .audio:
                try environment.engagementLauncher.startAudioCall()
            case .video:
                try environment.engagementLauncher.startVideoCall()
            case .secureMessaging:
                try environment.engagementLauncher.startSecureMessaging()
            }
        } catch {
            viewState = .error
        }
    }

    func makeViewModel(showHeader: Bool) -> EntryWidgetView.Model {
        let viewModel = EntryWidgetView.Model(
            theme: environment.theme,
            showHeader: showHeader,
            sizeConstraints: sizeConstraints,
            viewStatePublisher: $viewState,
            mediaTypeSelected: mediaTypeSelected(_:)
        )

        viewModel.retryMonitoring = { [weak self] in
            self?.viewState = .loading
            self?.environment.queuesMonitor.startMonitoring(queuesIds: self?.queueIds ?? [])
        }

        return viewModel
    }

    func showView(in parentView: UIView) {
        parentView.subviews.forEach { $0.removeFromSuperview() }
        let model = makeViewModel(showHeader: false)
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
        let model = makeViewModel(showHeader: true)
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
                return self.calculateHeight()
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

        observeViewState()
    }

    func observeViewState() {
        $viewState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.viewStateDidChange(state)
            }
            .store(in: &cancellables)
    }

    func viewStateDidChange(_ state: ViewState) {
        let newHeight = calculateHeight()

        if #available(iOS 16.0, *) {
            if let sheet = hostedViewController?.sheetPresentationController {
                let smallDetent = UISheetPresentationController.Detent.custom { _ in
                    return newHeight
                }
                sheet.detents = [smallDetent]
                sheet.animateChanges {
                    sheet.selectedDetentIdentifier = nil
                }
            }
        } else {
            if let customPresentationController = hostedViewController?.presentationController as? CustomPresentationController {
                customPresentationController.updateHeight(to: newHeight)
            }
        }
    }

    func calculateHeight() -> CGFloat {
        var mediaTypesCount: Int
        switch viewState {
        case .mediaTypes(let mediaTypes):
            mediaTypesCount = mediaTypes.count
        case .loading, .error, .offline:
            // 4 gives the desired fixed size
            mediaTypesCount = 4
        }
        var appliedHeight: CGFloat = 0
        appliedHeight += sizeConstraints.sheetHeaderHeight
        appliedHeight += CGFloat(mediaTypesCount) * (sizeConstraints.singleCellHeight + sizeConstraints.dividerHeight)
        appliedHeight += sizeConstraints.poweredByContainerHeight

        return appliedHeight
    }

    func makeView(model: EntryWidgetView.Model) -> EntryWidgetView {
        .init(model: model)
    }
}

// MARK: - View State
extension EntryWidget {
    enum ViewState {
        case loading
        case mediaTypes([MediaTypeItem])
        case offline
        case error
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension EntryWidget: UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let height = calculateHeight()
        return CustomPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            height: height,
            cornerRadius: environment.theme.entryWidget.cornerRadius
        )
    }
}
