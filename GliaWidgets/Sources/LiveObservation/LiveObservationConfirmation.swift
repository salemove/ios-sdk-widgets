import Foundation

extension LiveObservation {
    struct Confirmation {
        let conf: ConfirmationAlertConfiguration
        let link: (WebViewController.Link) -> Void
        let accepted: () -> Void
        let declined: () -> Void
    }
}
