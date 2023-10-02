import Foundation

extension LiveObservation {
    struct Confirmation {
        let conf: ConfirmationAlertConfiguration
        let accepted: () -> Void
        let declined: () -> Void
    }
}
