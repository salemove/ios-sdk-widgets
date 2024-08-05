import Foundation

extension UserImageView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
    }
}

extension UserImageView.Environment {
    static func create(with environment: UnreadMessageIndicatorView.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache
        )
    }

    static func create(with environment: BubbleView.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache
        )
    }

    static func create(with environment: ConnectOperatorView.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache
        )
    }

    static func create(with environment: GvaGalleryListView.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache
        )
    }

    static func create(with environment: GvaResponseTextView.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache
        )
    }

    static func create(with environment: CustomCardContainerView.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache
        )
    }

    static func create(with environment: OperatorChatMessageView.Environment) -> Self {
        .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache
        )
    }
}
