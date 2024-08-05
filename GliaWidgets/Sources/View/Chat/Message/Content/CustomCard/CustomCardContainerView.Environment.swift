import Foundation

extension CustomCardContainerView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiScreen: UIKitBased.UIScreen
    }
}

extension CustomCardContainerView.Environment {
    static func create(with environment: ChatView.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache,
            uiScreen: environment.uiScreen
        )
    }
}

#if DEBUG
extension CustomCardContainerView.Environment {
    static func mock(
        data: FoundationBased.Data = .mock,
        uuid: @escaping () -> UUID = { .mock },
        gcd: GCD = .mock,
        imageViewCache: ImageView.Cache = .mock,
        uiScreen: UIKitBased.UIScreen = .mock
    ) -> CustomCardContainerView.Environment {
        .init(
            data: data,
            uuid: uuid,
            gcd: gcd,
            imageViewCache: imageViewCache,
            uiScreen: uiScreen
        )
    }
}
#endif
