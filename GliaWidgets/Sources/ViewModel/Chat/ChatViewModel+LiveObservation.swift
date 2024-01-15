import Foundation

extension ChatViewModel {
    func showSnackBarIfNeeded() {
        guard siteConfiguration?.mobileObservationEnabled == true else { return }
        guard siteConfiguration?.mobileObservationIndicationEnabled == true else { return }
        action?(.showSnackBarView)
    }
}
