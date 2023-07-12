import Foundation

struct GvaResponseText: Decodable, Equatable {
    let type: GvaCardType
    let content: NSAttributedString

    enum CodingKeys: String, CodingKey {
        case type, content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(GvaCardType.self, forKey: .type)
        let contentString = try container.decode(String.self, forKey: .content)
        let modifiedString = contentString.replacingOccurrences(of: "\n", with: "</br>")
        content = modifiedString.htmlToAttributedString ?? NSAttributedString(string: "")
    }
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

private extension StringProtocol {
    var htmlToAttributedString: NSAttributedString? {
        Data(utf8).htmlToAttributedString
    }
    var htmlToString: String {
        htmlToAttributedString?.string ?? ""
    }
}

private extension Data {
    var htmlToAttributedString: NSAttributedString? {
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            return try NSAttributedString(
                data: self,
                options: options,
                documentAttributes: nil
            )
        } catch {
            debugPrint("HTML-string decoding failed with error:", error)
            return  nil
        }
    }
    var htmlToString: String { htmlToAttributedString?.string ?? "" }
}
