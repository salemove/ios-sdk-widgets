import Foundation
import Combine
import UIKit

/// Call Visualizer is a feature for operators to transfer their visitors from conventional communication methods,
/// such as a phone call, to Glia solution. The visitor needs to provide to the operator a visitor code,
/// which they will find in their app either via alert or embedded view. By telling the code to the operator, they can
/// initiate engagement with the visitor directly through the app.
///
/// Call Visualizer class facilitates everything related to this feature:
///  1. Requesting and displaying visitor code
///  2. Starting an engagement once the visitor code has been submitted by the operator
///  3. Handling engagement, featuring video calling, screen sharing, and much more in future.
public final class CallVisualizer {
    private var environment: Environment
    var delegate: ((Action) -> Void)?
    private var interactorSubscription: AnyCancellable?
    private(set) var activeInteractor: Interactor?
    lazy var coordinator: Coordinator = {
        let viewFactory = ViewFactory(
            with: environment.theme,
            messageRenderer: nil,
            environment: .create(with: environment)
        )
        return Coordinator(
            environment: .create(
                with: environment,
                viewFactory: viewFactory,
                eventHandler: { [weak self] event in
                    switch event {
                    case .minimized:
                        self?.environment.eventHandler?(.minimized)
                    case .maximized:
                        self?.environment.eventHandler?(.maximized)
                    }
                }
            )
        )
    }()

    init(environment: Environment) {
        self.environment = environment
    }

    /// Show VisitorCode popup alert for current Visitor.
    ///
    /// Call Visualizer Operators use the Visitor's code to start a Call Visualizer Engagement with the Visitor.
    ///
    /// Each Visitor code is generated on demand and is unique for every Visitor on a particular site. Upon the first time
    /// this function is called for a Visitor the code is generated and returned. For each successive call thereafter the
    /// same code will be returned as long as the code has not expired. During that time the code can be used to initiate an engagement.
    /// Once Operator uses the Visitor code to initiate an engagement, the code will expire immediately. When the Visitor Code
    /// expires this function will return a new Visitor code.
    ///
    /// - Parameters:
    ///   - source: The current `viewController` to present from.
    ///
    public func showVisitorCodeViewController(from source: UIViewController) {
        environment.log.prefixed(Self.self).info("Show Visitor Code Dialog")
        coordinator.showVisitorCodeViewController(by: .alert(source))
    }

    /// Show VisitorCode embedded view for current Visitor.
    ///
    /// Call Visualizer Operators use the Visitor's code to start a Call Visualizer Engagement with the Visitor.
    ///
    /// Each Visitor code is generated on demand and is unique for every Visitor on a particular site. Upon the first time
    /// this function is called for a Visitor the code is generated and returned. For each successive call thereafter the
    /// same code will be returned as long as the code has not expired. During that time the code can be used to initiate an engagement.
    /// Once Operator uses the Visitor code to initiate an engagement, the code will expire immediately. When the Visitor Code
    /// expires this function will return a new Visitor code.
    ///
    /// - Parameters:
    ///   - container: The view into which you want to embed VisitorCode view.
    ///   - onEngagementAccepted: callback can be used, that is called when engagement has been accepted.
    ///     One of the use cases may be calling for visitor code again, because in the moment when engagement
    ///     was accepted, the displayed visitor code became obsolete.
    ///
    public func embedVisitorCodeView(
        into container: UIView,
        onEngagementAccepted: @escaping () -> Void
    ) {
        environment.log.prefixed(Self.self).info("Show Visitor Code Dialog")
        coordinator.showVisitorCodeViewController(
            by: .embedded(container, onEngagementAccepted: onEngagementAccepted)
        )
    }

    public func resume() {
        coordinator.resume()
    }
}

// MARK: - Internal

extension CallVisualizer {
    func handleAcceptedUpgrade() {
        environment.log.prefixed(Self.self).info("Incoming Call Visualizer engagement auto accepted")
        coordinator.handleAcceptedUpgrade()
    }

    func handleEngagementRequest(request: CoreSdkClient.Request, answer: Command<Bool>) {
        coordinator.handleEngagementRequest(request: request, answer: answer)
    }

    func addVideoStream(stream: CoreSdkClient.VideoStreamable) {
        coordinator.addVideoStream(stream: stream)
    }

    func endSession() {
        coordinator.end()
        activeInteractor?.cleanup()
        delegate?(.engagementEnded)
    }

    func handleRestoredEngagement() {
        coordinator.showSnackBarIfNeeded()
    }

    func observeScreenSharingHandlerState() {
        coordinator.observeScreenSharingHandlerState()
    }

    func restoreVideoIfPossible() {
        guard let engagement = environment.getCurrentEngagement(), engagement.source == .callVisualizer && engagement.mediaStreams.video != nil else {
            return
        }
        coordinator.restoreVideoCall()
    }
}

// MARK: - Interactor Events

extension CallVisualizer {
    func startObservingInteractorEvents() {
        interactorSubscription = environment.interactorPublisher
            .sink { [weak self] newInteractor in
                guard let self else { return }
                handleInteractorEvents(newInteractor)
            }
    }

    func handleInteractorEvents(_ newInteractor: Interactor?) {
        self.activeInteractor?.removeObserver(self)
        self.activeInteractor = newInteractor
        newInteractor?.addObserver(self) { [weak self] event in
            guard let self else { return }
            if case .stateChanged(.ended(.byOperator)) = event,
               let endedEngagement = activeInteractor?.endedEngagement,
               endedEngagement.source == .callVisualizer {
                endSession()
                environment.log.prefixed(Self.self).info("Call visualizer engagement ended")
                return
            }
            guard
                let engagement = self.environment.getCurrentEngagement(),
                engagement.source == .callVisualizer
            else {
                switch event {
                case let .onEngagementRequest(request, answer):
                    handleEngagementRequest(request: request, answer: answer)
                default:
                    break
                }
                return
            }
            switch event {
            case .screenShareOffer(answer: let answer):
                environment.coreSdk.requestEngagedOperator { operators, _ in
                    self.environment.alertManager.present(
                        in: .global,
                        as: .screenSharing(
                            operators: operators?.compactMap { $0.name }.joined(separator: ", ") ?? "",
                            accepted: { [weak self] in
                                self?.observeScreenSharingHandlerState()
                            },
                            answer: answer
                        )
                    )
                }
            case let .upgradeOffer(offer, answer):
                environment.coreSdk.requestEngagedOperator { operators, _ in
                    self.environment.alertManager.present(
                        in: .global,
                        as: .mediaUpgrade(
                            operators: operators?.compactMap { $0.name }.joined(separator: ", ") ?? "",
                            offer: offer,
                            accepted: { [weak self] in
                                self?.handleAcceptedUpgrade()
                            },
                            answer: answer
                        )
                    )
                }
            case let .videoStreamAdded(stream):
                addVideoStream(stream: stream)
            case let .stateChanged(state):
                if case .engaged = state {
                    environment.log.prefixed(Self.self).info("New Call visualizer engagement loaded")
                    delegate?(.engagementStarted)
                    environment.log.prefixed(Self.self).info("Engagement started")
                }
            case let .screenSharingStateChanged(state):
                environment.screenShareHandler.updateState(state)
            default:
                break
            }
        }
    }
}
