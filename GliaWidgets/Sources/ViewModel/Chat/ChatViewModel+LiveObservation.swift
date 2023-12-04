import Foundation

extension ChatViewModel {
    func showSnackBarIfNeeded() {
        if siteConfiguration?.mobileObservationIndicationEnabled == true {
            action?(.showSnackBarView)
        }
    }
}
