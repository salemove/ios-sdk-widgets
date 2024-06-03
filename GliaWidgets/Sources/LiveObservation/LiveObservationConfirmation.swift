import Foundation

extension LiveObservation {
    struct Confirmation {
        let link: (WebViewController.Link) -> Void
        let accepted: () -> Void
        let declined: () -> Void
    }
}
