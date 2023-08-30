@testable import GliaWidgets
import Foundation

extension GvaResponseText {
    static func mock(
        type: GvaCardType,
        content: NSMutableAttributedString = .init(string: "")
    ) -> GvaResponseText {
        .init(
            type: type,
            content: content
        )
    }
}

extension GvaButton {
    static func mock(
        type: GvaCardType,
        content: NSMutableAttributedString = .init(string: ""),
        options: [GvaOption] = []
    ) -> GvaButton {
        .init(
            type: type,
            content: content,
            options: options
        )
    }
}

extension GvaGallery {
    static func mock(
        type: GvaCardType,
        galleryCards: [GvaGalleryCard] = []
    ) -> GvaGallery {
        .init(
            type: type,
            galleryCards: galleryCards
        )
    }
}
