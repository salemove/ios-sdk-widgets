import Foundation

extension ChatViewModel {
    func showSnackBarIfNeeded() {
        guard siteConfiguration?.mobileObservationEnabled == true else { return }
        guard siteConfiguration?.mobileObservationIndicationEnabled == true else { return }
        // If engagement has been restarted, visitor seen the acknowledgement and snackbar, so skip
        // it for restarting/restoring engagement.
        guard interactor.skipLiveObservationConfirmations == false else { return }

        let style = environment.viewFactory.theme.snackBar
        action?(.showSnackBarView(dismissTiming: .default, style: style))
    }
}
