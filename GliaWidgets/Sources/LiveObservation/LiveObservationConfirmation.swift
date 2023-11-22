import Foundation

extension LiveObservation {
    struct Confirmation {
        let conf: ConfirmationAlertConfiguration
        let link: (URL) -> Void
        let accepted: () -> Void
        let declined: () -> Void
    }
}
