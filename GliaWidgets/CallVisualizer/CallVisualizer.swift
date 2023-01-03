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
    private var visitorCodeCoordinator: VisitorCodeCoordinator?

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
    public func showVisitorCodeViewController(
        by presentation: Presentation,
        uiConfig: RemoteConfiguration? = nil
    ) {
        let coordinator = VisitorCodeCoordinator(
            environment: .init(
                timerProviding: environment.timerProviding,
                requestVisitorCode: environment.requestVisitorCode
            ),
            presentation: presentation,
            uiConfig: uiConfig
        )

        coordinator.delegate = { [weak self] event in
            switch event {
            case .closeTap:
                self?.visitorCodeCoordinator = nil
            }
        }

        /// FlowCoordinator protocol requires start() to return a viewController, but it won't be used in Call Visualizer context.
        /// Instead, it is handled seperately because of its unique nature.
        _ = coordinator.start()

        self.visitorCodeCoordinator = coordinator
    }
}
