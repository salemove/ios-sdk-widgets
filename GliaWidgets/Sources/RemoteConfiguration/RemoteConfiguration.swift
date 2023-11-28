import Foundation

public struct RemoteConfiguration: Codable {
    let globalColors: GlobalColors?
    let callScreen: Call?
    let chatScreen: Chat?
    let surveyScreen: Survey?
    let alert: Alert?
    let bubble: Bubble?
    let callVisualizer: CallVisualizer?
    let secureConversationsWelcomeScreen: SecureConversationsWelcomeScreen?
    let secureConversationsConfirmationScreen: SecureConversationsConfirmationScreen?
    let snackBar: SnackBar?
    let webBrowserScreen: WebView?
}

extension RemoteConfiguration {
    struct GlobalColors: Codable {
        let primary: String?
        let secondary: String?
        let baseNormal: String?
        let baseLight: String?
        let baseDark: String?
        let baseShade: String?
        let systemNegative: String?
        let baseNeutral: String?
    }
}

extension RemoteConfiguration {
    struct Call: Codable {
        let background: Layer?
        let bottomText: Text?
        let buttonBar: ButtonBar?
        let duration: Text?
        let header: Header?
        let callOperator, topText: Text?
        let connect: EngagementStates?

        enum CodingKeys: String, CodingKey {
            case background, bottomText, buttonBar, duration, header, connect
            case callOperator = "operator"
            case topText
        }
    }

    struct Alert: Codable {
        let title: Text?
        let titleImageColor: Color?
        let message: Text?
        let backgroundColor: Color?
        let closeButtonColor: Color?
        let linkButton: Button?
        let positiveButton: Button?
        let negativeButton: Button?
        let buttonAxis: Axis?
    }

    enum Axis: String, Codable {
        case horizontal
        case vertical
    }

    struct Bubble: Codable {
        let badge: Badge?
        let onHoldOverlay: OnHoldOverlayStyle?
        let userImage: UserImageStyle?
    }

    struct Badge: Codable {
        let background: Layer?
        let font: Font?
        let fontColor: Color?
    }

    struct OnHoldOverlayStyle: Codable {
        let backgroundColor: Color?
        let tintColor: Color?
    }

    struct UserImageStyle: Codable {
        let imageBackgroundColor: Color?
        let placeholderBackgroundColor: Color?
        let placeholderColor: Color?
    }

    struct Layer: Codable {
        let border: Color?
        let borderWidth: Double?
        let cornerRadius: Double?
        let color: Color?
    }

    struct Color: Codable {
        let type: ColorType
        let value: [String]
    }

    enum ColorType: String, Codable {
        case fill
        case gradient
    }

    struct Button: Codable {
        let background: Layer?
        let text: Text?
        let tintColor: Color?
        let shadow: Shadow?
    }

    struct Shadow: Codable {
        let color: Color?
        let offset: Double?
        let opacity, radius: Double?
    }

    struct Text: Codable {
        let alignment: Alignment?
        let background: Color?
        let font: Font?
        let foreground: Color?
    }

    enum Alignment: String, Codable {
        case center
        case leading
        case trailing
    }

    public struct Font: Codable {
        public let size: Double?
        public let style: FontStyle?
    }

    public enum FontStyle: String, Codable {
        case bold, italic, regular, thin
    }

    struct ButtonBar: Codable {
        let chatButton, minimizeButton, muteButton, speakerButton: BarButtonStates?
        let videoButton: BarButtonStates?
        let badge: Badge?
    }

    struct BarButtonStates: Codable {
        let active: BarButtonStyle?
        let inactive: BarButtonStyle?
        let selected: BarButtonStyle?
    }

    struct BarButtonStyle: Codable {
        let background, imageColor: Color?
        let title: Text?
    }

    struct Survey: Codable {
        let title: Text?
        let layer: Layer?
        let submitButton: Button?
        let cancelButton: Button?
        let booleanQuestion: SurveyBooleanQuestion?
        let inputQuestion: SurveyInputQuestion?
        let scaleQuestion: SurveyScaleQuestion?
        let singleQuestion: SurveySingleQuestion?
    }

    struct SurveyBooleanQuestion: Codable {
        let optionButton: OptionButton?
        let title: Text?
    }

    struct OptionButton: Codable {
        let font: Font?
        let highlightedLayer: Layer?
        let highlightedText: Text?
        let normalLayer: Layer?
        let normalText: Text?
        let selectedLayer: Layer?
        let selectedText: Text?
    }

    struct SurveyInputQuestion: Codable {
        let background: Layer?
        let option: OptionButton?
        let text, title: Text?
    }

    struct SurveyScaleQuestion: Codable {
        let optionButton: OptionButton?
        let title: Text?
    }

    struct SurveySingleQuestion: Codable {
        let option: Text?
        let tintColor: Color?
        let title: Text?
    }
}
