import Foundation
import UIKit
import GliaCoreSDK

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
    lazy var coordinator: Coordinator = {
        let viewFactory = ViewFactory(
            with: environment.theme,
            messageRenderer: nil,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen,
                log: environment.log
            )
        )
        return Coordinator(
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen,
                uiDevice: environment.uiDevice,
                notificationCenter: environment.notificationCenter,
                viewFactory: viewFactory,
                presenter: environment.callVisualizerPresenter,
                bundleManaging: environment.bundleManaging,
                screenShareHandler: environment.screenShareHandler,
                timerProviding: environment.timerProviding,
                requestVisitorCode: environment.requestVisitorCode,
                audioSession: environment.audioSession,
                date: environment.date,
                engagedOperator: environment.engagedOperator,
                eventHandler: { [weak self] event in
                    switch event {
                    case .minimized:
                        self?.environment.eventHandler?(.minimized)
                    case .maximized:
                        self?.environment.eventHandler?(.maximized)
                    }
                },
                orientationManager: environment.orientationManager,
                proximityManager: environment.proximityManager,
                log: environment.log,
                interactorProviding: environment.interactorProviding(),
                fetchSiteConfigurations: environment.fetchSiteConfigurations,
                snackBar: environment.snackBar
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
    /// - Parameter source: The current viewController to present from.
    ///
    public func showVisitorCodeViewController(from source: UIViewController) {
        environment.log.prefixed(Self.self).info("Show Visitor Code Dialog")
        delegate?(.visitorCodeIsRequested)
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
    ///   One of the use cases may be calling for visitor code again, because in the moment when engagement
    ///   was accepted, the displayed visitor code becomes obsolete.
    ///
    public func embedVisitorCodeView(
        into container: UIView,
        onEngagementAccepted: @escaping () -> Void
    ) {
        environment.log.prefixed(Self.self).info("Show Visitor Code Dialog")
        delegate?(.visitorCodeIsRequested)
        coordinator.showVisitorCodeViewController(
            by: .embedded(container, onEngagementAccepted: onEngagementAccepted)
        )
    }
}

// MARK: - Internal

extension CallVisualizer {
    func handleAcceptedUpgrade() {
        environment.log.prefixed(Self.self).info("Incoming Call Visualizer engagement auto accepted")
        coordinator.handleAcceptedUpgrade()
    }

    func handleEngagementRequestAccepted(_ answer: Command<Bool>) {
        coordinator.handleEngagementRequestAccepted(answer)
    }

    func addVideoStream(stream: CoreSdkClient.VideoStreamable) {
        coordinator.addVideoStream(stream: stream)
    }

    func endSession() {
        coordinator.end()
        stopObservingInteractorEvents()
    }

    func handleRestoredEngagement() {
        coordinator.showSnackBarIfNeeded()
    }

    func observeScreenSharingHandlerState() {
        coordinator.observeScreenSharingHandlerState()
    }
}

// MARK: - Interactor Events

extension CallVisualizer {
    func startObservingInteractorEvents() {
        environment.interactorProviding()?.addObserver(self) { [weak self] event in
            guard let engagement = self?.environment.getCurrentEngagement(), engagement.source == .callVisualizer else {
                return
            }
            switch event {
            case let .screenSharingStateChanged(state):
                self?.environment.screenShareHandler.updateState(state)
            case .stateChanged(.ended):
                self?.environment.log.prefixed(Self.self).info("Call visualizer engagement ended")
            default:
                break
            }
        }
    }

    func stopObservingInteractorEvents() {
        environment.interactorProviding()?.removeObserver(self)
    }
}
