import Foundation

public struct RemoteConfiguration: Codable {
    public let chatScreen: Chat?
}

public extension RemoteConfiguration {

    struct Chat: Codable {
        public let background: Layer?
        public let endButton: Button?
        public let header: Header?
        public let operatorMessage: MessageBalloon?
        public let visitorMessage: MessageBalloon?
    }

    struct Layer: Codable {
        public let border: Color?
        public let borderWidth: Double?
        public let cornerRadius: Double?
        public let foreground: Color?
    }

    struct Color: Codable {
        public let value: [ColorType]?
    }

    enum ColorType: String, Codable {
        case fill
        case gradient
    }

    struct Button: Codable {
        public let background: Color?
        public let text: Text?
    }

    struct Text: Codable {
        public let alignment: [Alignment]?
        public let background: Color?
        public let font: Font?
        public let foreground: Color?
    }

    enum Alignment: String, Codable {
        case center
        case leading
        case trailing
    }

    struct Font: Codable {
        public let size: Double?
        public let style: [FontStyle]?
    }

    enum FontStyle: String, Codable {
        case bold, italic, regular, thin
    }

    struct Header: Codable {
        public let background: Layer?
        public let text: Text?
    }

    struct MessageBalloon: Codable {
        public let alignment: [Alignment]?
        public let background: Layer?
        public let text: Text?
    }
}
