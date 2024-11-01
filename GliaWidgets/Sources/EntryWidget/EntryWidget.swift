import Combine
import Foundation
import GliaCoreSDK
import UIKit
import SwiftUI

/// The `EntryWidget` class is a customizable UI component designed to display
/// engagement options (such as chat, audio, video, or secure messaging) based on
/// the availability of media types in the given queues. It offers functionality to
/// either embed itself within a view or present as a modal sheet.
public final class EntryWidget: NSObject {
    private(set) var hostedViewController: UIViewController?
    private var embeddedView: UIView?
    private var queueIds: [String]
    private var cancellables = CancelBag()
    private let environment: Environment

    @Published var viewState: ViewState = .loading

    static let sizeConstraints: SizeConstraints = .init(
        singleCellHeight: 72,
        singleCellIconSize: 24,
        poweredByContainerHeight: 40,
        sheetHeaderHeight: 36,
        sheetHeaderDraggerWidth: 32,
        sheetHeaderDraggerHeight: 4,
        dividerHeight: 1
    )

    // MARK: - Initialization

    /// Initializes the `EntryWidget` with queue identifiers and an environment.
    ///
    /// - Parameters:
    ///   - queueIds: An array of strings representing the queue identifiers.
    ///   - environment: An `Environment` object containing external dependencies.
    init(queueIds: [String], environment: Environment) {
        self.queueIds = queueIds
        self.environment = environment
        super.init()

        environment.queuesMonitor.$state
            .sink(receiveValue: handleQueuesMonitorUpdates(state:))
            .store(in: &cancellables)
    }
}

// MARK: - Public methods
public extension EntryWidget {
    /// Displays the widget as a modal sheet in the given view controller.
    ///
    /// - Parameter viewController: The `UIViewController` in which the widget will be shown as a sheet.
    func show(in viewController: UIViewController) {
        showSheet(in: viewController)
    }

    /// Embeds the widget as a view in the given parent view.
    ///
    /// - Parameter view: The `UIView` in which the widget will be embedded.
    func embed(in view: UIView) {
        showView(in: view)
    }

    /// Hides the widget, dismissing any presented sheets and stopping queue monitoring.
    func hide() {
        hostedViewController?.dismiss(animated: true, completion: nil)
        hostedViewController = nil
        environment.queuesMonitor.stopMonitoring()
    }
}

extension EntryWidget {
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
        appliedHeight += EntryWidget.sizeConstraints.sheetHeaderHeight
        appliedHeight += CGFloat(mediaTypesCount) * (EntryWidget.sizeConstraints.singleCellHeight + EntryWidget.sizeConstraints.dividerHeight)
        appliedHeight += EntryWidget.sizeConstraints.poweredByContainerHeight

        return appliedHeight
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
        if !environment.isAuthenticated() {
            availableMediaTypes.remove(.secureMessaging)
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
            sizeConstraints: EntryWidget.sizeConstraints,
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
        self.environment.queuesMonitor.startMonitoring(queuesIds: self.queueIds)
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
        self.environment.queuesMonitor.startMonitoring(queuesIds: self.queueIds)
        let model = makeViewModel(showHeader: true)
        let view = makeView(model: model).accessibilityAction(.escape, {
            self.hide()
        })
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
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
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

#if DEBUG
extension EntryWidget {
    static func mock() -> Self {
        .init(queueIds: [], environment: .mock())
    }
}

#endif
