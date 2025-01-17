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
    private let configuration: Configuration
    private let environment: Environment
    @Published private var unreadSecureMessageCount: Int?
    private(set) var unreadSecureMessageSubscriptionId: String?
    @Published var viewState: ViewState = .loading
    private var ongoingEngagement: Engagement?
    private var interactorState: InteractorState = .none
    private var cancellables = CancelBag()

    // MARK: - Initialization

    /// Initializes the `EntryWidget` with queue identifiers and an environment.
    ///
    /// - Parameters:
    ///   - queueIds: An array of strings representing the queue identifiers.
    ///   - environment: An `Environment` object containing external dependencies.
    init(
        queueIds: [String],
        configuration: Configuration,
        environment: Environment
    ) {
        self.queueIds = queueIds
        self.configuration = configuration
        self.environment = environment
        super.init()

        observeSecureUnreadMessageCount()

        Publishers.CombineLatest(environment.queuesMonitor.$state, $unreadSecureMessageCount)
            .sink(receiveValue: handleQueuesMonitorUpdates(state:unreadSecureMessagesCount:))
            .store(in: &cancellables)

        environment.currentInteractor()?.$currentEngagement
            .sink { [weak self] engagement in
                guard let self else { return }
                ongoingEngagement = engagement
                handleQueuesMonitorUpdates(state: environment.queuesMonitor.state, unreadSecureMessagesCount: unreadSecureMessageCount)
            }
            .store(in: &cancellables)

        environment.currentInteractor()?.$state
            .sink { [weak self] state in
                guard let self else { return }
                interactorState = state
                handleQueuesMonitorUpdates(state: environment.queuesMonitor.state, unreadSecureMessagesCount: unreadSecureMessageCount)
            }
            .store(in: &cancellables)
    }

    deinit {
        if let unreadSecureMessageSubscriptionId {
            environment.unsubscribeFromUpdates(unreadSecureMessageSubscriptionId) { [environment] error in
                environment.log.prefixed(Self.self).warning(
                    "Unsubscribing from unread secure messages count without configured SDK: \(error.localizedDescription)"
                )
            }
        }
    }
}

// MARK: - Public methods
public extension EntryWidget {
    /// Displays the widget as a modal sheet in the given view controller. If there is an ongoing secure conversation, the Chat Transcript screen will be opened instead.
    ///
    /// - Parameter viewController: The `UIViewController` in which the widget will be shown as a sheet.
    func show(in viewController: UIViewController) {
        if environment.hasPendingInteraction() {
            do {
                try environment.engagementLauncher.startSecureMessaging()
            } catch {
                viewState = .error
            }
        } else {
            showSheet(in: viewController)
        }
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
        case .ongoingEngagement:
            mediaTypesCount = 1
        }
        var appliedHeight: CGFloat = 0
        appliedHeight += configuration.sizeConstraints.sheetHeaderHeight
        appliedHeight += CGFloat(mediaTypesCount) * (configuration.sizeConstraints.singleCellHeight + configuration.sizeConstraints.dividerHeight)
        appliedHeight += configuration.sizeConstraints.poweredByContainerHeight

        return appliedHeight
    }

    func mediaTypeSelected(_ mediaTypeItem: MediaTypeItem) {
        if let configurationAction = configuration.mediaTypeSelected {
            configurationAction(mediaTypeItem)
            return
        }
        hideViewIfNecessary {
            do {
                switch mediaTypeItem.type {
                case .chat:
                    try self.environment.engagementLauncher.startChat()
                case .audio:
                    try self.environment.engagementLauncher.startAudioCall()
                case .video:
                    try self.environment.engagementLauncher.startVideoCall()
                case .secureMessaging:
                    try self.environment.engagementLauncher.startSecureMessaging()
                case .callVisualizer:
                    self.environment.onCallVisualizerResume()
                }
            } catch {
                self.viewState = .error
            }
        }
    }
}

// MARK: - Private methods
private extension EntryWidget {
    func observeSecureUnreadMessageCount() {
        self.unreadSecureMessageSubscriptionId = environment.observeSecureUnreadMessageCount { [weak self] result in
            guard let self else {
                return
            }
            let messagesCount = try? result.get()
            self.unreadSecureMessageCount = messagesCount ?? 0
        }
    }

    func resolveAvailableEngagementTypes(from queues: [Queue]) -> [EngagementType] {
        var availableMediaTypes: Set<EngagementType> = []

        queues.forEach { queue in
            queue.state.media.forEach { mediaType in
                if let mediaTypeItem = EngagementType(mediaType: mediaType) {
                    availableMediaTypes.insert(mediaTypeItem)
                }
            }
        }
        if !environment.isAuthenticated() || configuration.filterSecureConversation {
            availableMediaTypes.remove(.secureMessaging)
        }

        return Array(availableMediaTypes).sorted(by: { $0.rawValue < $1.rawValue })
    }

    func hideViewIfNecessary(completion: @escaping () -> Void) {
        guard hostedViewController != nil else {
            completion()
            return
        }
        hostedViewController?.dismiss(animated: true, completion: completion)
        hostedViewController = nil
    }

    func makeViewModel(showHeader: Bool) -> EntryWidgetView.Model {
        let viewModel = EntryWidgetView.Model(
            theme: environment.theme,
            showHeader: showHeader,
            configuration: configuration,
            viewStatePublisher: $viewState,
            mediaTypeSelected: mediaTypeSelected(_:)
        )

        viewModel.retryMonitoring = { [weak self] in
            self?.viewState = .loading
            self?.environment.queuesMonitor.fetchAndMonitorQueues(queuesIds: self?.queueIds ?? [])
        }

        return viewModel
    }

    func showView(in parentView: UIView) {
        self.environment.queuesMonitor.fetchAndMonitorQueues(queuesIds: self.queueIds)
        parentView.subviews.forEach { $0.removeFromSuperview() }
        let model = makeViewModel(showHeader: false)
        let view = makeView(model: model)
        let hostingController = UIHostingController(rootView: view)

        parentView.addSubview(hostingController.view)
        hostingController.view.clipsToBounds = true
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.widthAnchor.constraint(equalTo: parentView.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: parentView.heightAnchor),
            hostingController.view.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])

        observeViewState { _ in
            hostingController.view.setNeedsUpdateConstraints()
        }

        embeddedView = hostingController.view
    }

    func showSheet(in parentViewController: UIViewController) {
        self.environment.queuesMonitor.fetchAndMonitorQueues(queuesIds: self.queueIds)
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

        observeViewState(updateSheetWithStateChange)
    }

    func observeViewState(_ receiveValue: @escaping (ViewState) -> Void) {
        $viewState
            .receive(on: RunLoop.main)
            .sink(receiveValue: receiveValue)
            .store(in: &cancellables)
    }

    func updateSheetWithStateChange(_ state: ViewState) {
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

// MARK: Queue Updates handling
private extension EntryWidget {
    func handleQueuesMonitorUpdates(
        state: QueuesMonitor.State,
        unreadSecureMessagesCount: Int?
    ) {
        if let ongoingState = resolveViewState(for: ongoingEngagement) {
            environment.log.info("Preparing items based on ongoing engagement")
            viewState = ongoingState
        } else if let enqueuedState = resolveViewState(for: interactorState) {
            environment.log.info("Preparing items based on ongoing engagement")
            viewState = enqueuedState
        } else {
            viewState = resolveViewState(
                for: state,
                unreadSecureMessagesCount: unreadSecureMessagesCount
            )
        }
    }

    func resolveViewState(for ongoingEngagement: Engagement?) -> EntryWidget.ViewState? {
        guard let ongoingEngagement else {
            return nil
        }

        if ongoingEngagement.source == .callVisualizer {
            return .ongoingEngagement(.callVisualizer)
        } else if ongoingEngagement.source == .coreEngagement {
            if ongoingEngagement.mediaStreams.video != nil {
                return .ongoingEngagement(.video)
            } else if ongoingEngagement.mediaStreams.audio != nil {
                return .ongoingEngagement(.audio)
            } else {
                return .ongoingEngagement(.chat)
            }
        }
        return nil
    }

    func resolveViewState(for interactorState: InteractorState) -> EntryWidget.ViewState? {
        guard let engagementKind = interactorState.enqueiengEngagementKind else {
            return nil
        }

        switch engagementKind {
        case .none:
            return nil
        case .chat:
            return .ongoingEngagement(.chat)
        case .audioCall:
            return .ongoingEngagement(.audio)
        case .videoCall:
            return .ongoingEngagement(.video)
        case .messaging:
            return .ongoingEngagement(.secureMessaging)
        }
    }

    func resolveViewState(
        for queuesMonitorState: QueuesMonitor.State,
        unreadSecureMessagesCount: Int?
    ) -> EntryWidget.ViewState {
        switch queuesMonitorState {
        case .idle:
            return .loading
        case .updated(let queues):
            let availableEngagementTypes = resolveAvailableEngagementTypes(from: queues)
            if availableEngagementTypes.isEmpty {
                return .offline
            } else {
                let mediaTypes = availableEngagementTypes.map { type in
                    if type == .secureMessaging {
                        return EntryWidget.MediaTypeItem(
                            type: type,
                            badgeCount: unreadSecureMessagesCount ?? 0
                        )
                    }
                    return EntryWidget.MediaTypeItem(type: type)
                }
                return .mediaTypes(mediaTypes)
            }
        case .failed(let error):
            environment.log.prefixed(Self.self).error("Setting up queues. Failed to get site queues \(error)")
            return .error
        }
    }
}

// MARK: - View State
extension EntryWidget {
    enum ViewState: Equatable {
        case loading
        case mediaTypes([MediaTypeItem])
        case offline
        case error
        case ongoingEngagement(EngagementType)
    }
}

private extension InteractorState {
    var enqueiengEngagementKind: EngagementKind? {
        switch self {
        case .enqueued(_, let engagementKind), .enqueueing(let engagementKind):
            return engagementKind
        case .none, .engaged, .ended:
            return nil
        }
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
    static func mock(configuration: EntryWidget.Configuration? = nil) -> Self {
        .init(queueIds: [], configuration: configuration ?? .default, environment: .mock())
    }
}

#endif
