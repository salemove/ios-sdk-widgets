import Foundation

public struct RemoteConfiguration: Codable {
    public let callScreen: Call?
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

    struct Call: Codable {
        let background: Layer?
        let bottomText: Text?
        let buttonBar: ButtonBar?
        let duration: Text?
        let endButton: Button?
        let header: Header?
        let callOperator, topText: Text?

        enum CodingKeys: String, CodingKey {
            case background, bottomText, buttonBar, duration, endButton, header
            case callOperator = "operator"
            case topText
        }
    }

    struct Layer: Codable {
        public let border: Color?
        public let borderWidth: Double?
        public let cornerRadius: Double?
        public let color: Color?
    }

    struct Color: Codable {
        let type: ColorType?
        let value: [String]?
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
        public let style: FontStyle?
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

    struct ButtonBar: Codable {
        let chatButton, minimizeButton, muteButton, speakerButton: BarButtonStates?
        let videoButton: BarButtonStates?
    }

    struct BarButtonStates: Codable {
        let active, inactive: BarButtonStyle?
    }

    struct BarButtonStyle: Codable {
        let background, imageColor: Color?
        let title: Text?
    }
}
