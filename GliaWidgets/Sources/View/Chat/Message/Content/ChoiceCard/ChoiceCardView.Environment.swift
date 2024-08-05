import Foundation

extension ChoiceCardView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiScreen: UIKitBased.UIScreen
    }
}

extension ChoiceCardView.Environment {
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
