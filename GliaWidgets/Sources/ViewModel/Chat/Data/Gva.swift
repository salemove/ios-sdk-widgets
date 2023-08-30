import Foundation

struct GvaResponseText: Equatable {
    let type: GvaCardType
    let content: NSMutableAttributedString

    enum CodingKeys: String, CodingKey {
        case type, content
    }
}

extension GvaResponseText: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(GvaCardType.self, forKey: .type)
        let contentString = try container.decode(String.self, forKey: .content)
        let modifiedString = contentString.replacingOccurrences(of: "\n", with: "</br>")
        content = modifiedString.htmlToAttributedString ?? NSMutableAttributedString(string: "")
    }
}

struct GvaButton: Equatable {
    let type: GvaCardType
    let content: NSMutableAttributedString
    let options: [GvaOption]

    enum CodingKeys: String, CodingKey {
        case type, content, options
    }
}

extension GvaButton: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(GvaCardType.self, forKey: .type)
        let contentString = try container.decode(String.self, forKey: .content)
        let modifiedString = contentString.replacingOccurrences(of: "\n", with: "</br>")
        content = modifiedString.htmlToAttributedString ?? NSMutableAttributedString(string: "")
        options = try container.decode([GvaOption].self, forKey: .options)
    }
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

struct GvaOption: Codable, Equatable {
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

enum GvaCardType: String, Codable {
    case persistentButtons
    case quickReplies
    case plainText
    case galleryCards
}

private extension StringProtocol {
    var htmlToAttributedString: NSMutableAttributedString? {
        Data(utf8).htmlToAttributedString
    }
    var htmlToString: String {
        htmlToAttributedString?.string ?? ""
    }
}

private extension Data {
    var htmlToAttributedString: NSMutableAttributedString? {
        if let string = String(data: self, encoding: .utf8), containsHtml(string) {
            do {
                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]
                return try NSMutableAttributedString(
                    data: self,
                    options: options,
                    documentAttributes: nil
                )
            } catch {
                debugPrint("HTML-string decoding failed with error:", error)
                return NSMutableAttributedString(string: string)
            }
        } else {
            return NSMutableAttributedString(string: String(data: self, encoding: .utf8) ?? "")
        }
    }

    func containsHtml(_ string: String) -> Bool {
        if string.range(of: "<[^>]+>", options: .regularExpression) == nil {
            return false
        }

        return true
    }

    var htmlToString: String { htmlToAttributedString?.string ?? "" }
}
