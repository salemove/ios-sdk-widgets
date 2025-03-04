import Foundation

extension SecureMessagingTopBannerView {
    struct Environment {
        var combineScheduler: AnyCombineScheduler
    }
}

extension SecureMessagingTopBannerView.Environment {
    static func create(with environment: ChatView.Environment) -> Self {
        .init(combineScheduler: environment.combineScheduler)
    }
}
