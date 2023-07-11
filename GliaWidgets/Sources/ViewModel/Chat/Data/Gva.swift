import Foundation

struct GvaResponseText: Decodable, Equatable {
    let type: GvaCardType
    let content: String
}

struct GvaButton: Decodable, Equatable {
    let type: GvaCardType
    let content: String
    let options: [GvaOption]
}

struct GvaGallery: Decodable, Equatable {
    let type: GvaCardType
    let galleryCards: [GvaGalleryCard]
}

struct GvaGalleryCard: Decodable, Equatable {
    let title: String
    let subtitle: String?
    let imageUrl: String?
    let options: [GvaOption]?
}

struct GvaOption: Decodable, Equatable {
    let text: String
    let value: String?
    let url: String?
    let urlTarget: String?
    let destinationPdBroadcastEvent: String?
}

enum GvaUrlTarget: String, Decodable {
    case modal
    case _self
    case blank

    enum CodingKeys: String, CodingKey {
        case modal
        case _self = "self"
        case blank
    }
}

enum GvaCardType: String, Decodable {
    case persistentButtons
    case quickReplies
    case plainText
    case galleryCards
}
