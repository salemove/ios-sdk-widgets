import Foundation

extension ChatViewModel {
    func showSnackBarIfNeeded() {
        if siteConfiguration?.observationIndication == true {
            action?(.showSnackBarView)
        }
    }
}
