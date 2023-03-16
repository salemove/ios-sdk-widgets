import Foundation
import UIKit
import SalemoveSDK

/// Call Visualizer is a feature for operators to transfer their visitors from conventional comunication methods,
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
    private lazy var coordinator: Coordinator = {
        var theme = Theme()
        if let uiConfig = environment.uiConfig() {
            theme = .init(uiConfig: uiConfig, assetsBuilder: environment.assetsBuilder())
        }
        let viewFactory = ViewFactory(
            with: theme,
            messageRenderer: nil,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication
            )
        )
        return Coordinator(
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                uiApplication: environment.uiApplication,
                viewFactory: viewFactory,
                presenter: environment.callVisualizerPresenter,
                bundleManaging: environment.bundleManaging,
                screenShareHandler: environment.screenShareHandler,
                timerProviding: environment.timerProviding,
                requestVisitorCode: environment.requestVisitorCode,
                audioSession: environment.audioSession,
                date: environment.date,
                engagedOperator: environment.engagedOperator
            )
        )
    }()

    init(environment: Environment) {
        self.environment = environment
    }

    /// Show VisitorCode for current Visitor.
    ///
    /// Call Visualizer Operators use the Visitor's code to start an Call Visualizer Engagement with the Visitor.
    ///
    /// Each Visitor code is generated on demand and is unique for every Visitor on a particular site. Upon the first time
    /// this function is called for a Visitor the code is generated and returned. For each successive call thereafter the
    /// same code will be returned as long as the code has not expired. During that time the code can be used to initiate an engagement.
    /// Once Operator uses the Visitor code to initiate an engagement, the code will expire immediately. When the Visitor Code
    /// expires this function will return a new Visitor code.
    ///
    /// Visitor code can be displayed in 2 ways:
    /// - `Popup alert`
    /// - `Embedded view`
    ///
    ///  The way of displaying is determined by the 'presentation' parameter. If choosing alert, the current viewController
    ///  needs to be passed in as an associated value. If, however, embedding is chosen, the view into which you want to
    ///  embed it has to be passed in as an associated value.
    ///
    ///  If embedded option is chosen, `onEngagementAccepted` callback can be used, that is called when engagement
    ///  has been accepted. One of the use cases may be calling for visitor code again, because in the moment when engagement
    ///  was accepted, the displayed visitor code becomes obsolete.
    public func showVisitorCodeViewController(
        by presentation: Presentation
    ) {
        coordinator.showVisitorCodeViewController(by: presentation)
    }
}

// MARK: - Internal

extension CallVisualizer {
    func handleAcceptedUpgrade() {
        coordinator.handleAcceptedUpgrade()
    }

    func handleEngagementRequestAccepted() {
        coordinator.handleEngagementRequestAccepted()
    }

    func addVideoStream(stream: CoreSdkClient.VideoStreamable) {
        coordinator.addVideoStream(stream: stream)
    }

    func endSession() {
        coordinator.end()
        stopObservingInteractorEvents()
    }

    func offerScreenShare(
        from operators: [CoreSdkClient.Operator],
        configuration: ScreenShareOfferAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        let acceptedHandler = { [weak self] in
            self?.startObservingInteractorEvents()
            accepted()
        }
        coordinator.offerScreenShare(
            from: operators,
            configuration: configuration,
            accepted: acceptedHandler,
            declined: declined
        )
    }

    func offerMediaUpgrade(
        from operators: [CoreSdkClient.Operator],
        offer: CoreSdkClient.MediaUpgradeOffer,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        let alertConfiguration = Theme().alertConfiguration
        switch offer.type {
        case .video:
            let configuration = offer.direction == .oneWay
            ? alertConfiguration.oneWayVideoUpgrade
            : alertConfiguration.twoWayVideoUpgrade
            coordinator.offerMediaUpgrade(
                from: operators,
                configuration: configuration,
                accepted: accepted,
                declined: declined
            )
        default:
            break
        }
    }
}

// MARK: - Private

private extension CallVisualizer {
    func startObservingInteractorEvents() {
        environment.interactorProviding()?.addObserver(self) { [weak self] event in
            guard let engagement = self?.environment.getCurrentEngagement(), engagement.source == .callVisualizer else {
                return
            }
            switch event {
            case let .screenSharingStateChanged(state):
                self?.environment.screenShareHandler.updateState(to: state)
            default:
                break
            }
        }
    }

    func stopObservingInteractorEvents() {
        environment.interactorProviding()?.removeObserver(self)
    }
}
