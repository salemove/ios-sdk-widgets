import Foundation

extension Glia {
    /// Resets the interactor and closes every piece of engagement UI Widgets owns, without
    /// contacting Core. Used after Core has already dropped the engagement (deauthentication,
    /// clearing the visitor session).
    ///
    /// - Parameter endedCallVisualizerEngagement: Pass `true` only when a Call Visualizer
    ///   engagement was ongoing, because ending its session reports `.ended` to the integrator.
    func closeEngagementUI(endedCallVisualizerEngagement: Bool = false) {
        interactor?.cleanup()
        closeRootCoordinator()
        if endedCallVisualizerEngagement {
            callVisualizer.endSession()
        }
        engagementRestorationState = .none
    }

    func closeRootCoordinator() {
        rootCoordinator?.popCoordinator()
        rootCoordinator?.end(surveyPresentation: .doNotPresentSurvey)
        rootCoordinator = nil
    }
}
