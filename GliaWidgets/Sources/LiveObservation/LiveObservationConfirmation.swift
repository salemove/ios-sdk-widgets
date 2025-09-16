import Foundation

extension LiveObservation {
    struct Confirmation {
        let link: (WebViewController.Link) -> Void
        let accepted: () async -> Void
        let declined: () async -> Void
    }
}
