import Foundation

public struct LLMContextPayload: Codable {
    public let screenName: String
    public let timestamp: String
    public let time_spent_in_seconds: Int?
    public let content: [String]?
    public let capturedOffsets: [OffsetCapture]?
}

public struct OffsetCapture: Codable {
    public let offset: Double
    public let content: [String]
}

public struct Element: Codable {
    public let type: ElementType
    public let text: String
}

public enum ElementType: String, Codable {
    case button
    case label
    case input
}

public class ScreenContextBuilder {
    private let jsonEncoder: JSONEncoder
    private let dateFormatter: ISO8601DateFormatter

    public init() {
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.outputFormatting = .prettyPrinted
        self.dateFormatter = ISO8601DateFormatter()
    }

    public func getCurrentTimestamp() -> String {
        return dateFormatter.string(from: Date())
    }

    public func groupElementsIntoLines(_ elements: [ScreenTextElement]) -> [Element] {
        guard !elements.isEmpty else { return [] }

        let sortedElements = elements.sorted { $0.frame.origin.y < $1.frame.origin.y }

        var lines = [[ScreenTextElement]]()
        var currentLine = [ScreenTextElement]()

        for element in sortedElements {
            if currentLine.isEmpty {
                currentLine.append(element)
                continue
            }

            guard let lineAnchor = currentLine.min(by: { $0.frame.origin.y < $1.frame.origin.y }) else {
                currentLine.append(element)
                continue
            }

            let midY1 = lineAnchor.frame.midY
            let midY2 = element.frame.midY
            let avgHeight = (lineAnchor.frame.height + element.frame.height) / 2.0

            if abs(midY1 - midY2) < (avgHeight * 0.5) {
                currentLine.append(element)
            } else {
                lines.append(currentLine)
                currentLine = [element]
            }
        }

        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        var result: [Element] = []
        for line in lines {
            let sortedLine = line.sorted { $0.frame.origin.x < $1.frame.origin.x }
            for item in sortedLine {
                result.append(Element(type: item.type, text: item.text))
            }
        }

        return result
    }
}

public struct ScreenTextElement {
    public let text: String
    public let type: ElementType
    public let frame: CGRect
}

public struct EngagementContext: Codable, Equatable {
    public let loans: Int
    public let accounts: Int
    public let insurance: Int
    public let transactions: Int
    public let overview: String
}

public struct QuickReplyContext: Codable, Equatable {
    public let quickReplies: [QuickReplyOption]
}

public struct QuickReplyOption: Codable, Equatable {
    public let text: String
    public let value: String
    public let message: String
}
