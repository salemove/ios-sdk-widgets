import Foundation
import UIKit

public struct RemoteConfiguration: Codable {
    let globalColors: GlobalColors?
    let callScreen: Call?
    let chatScreen: Chat?
    let surveyScreen: Survey?
    let alert: Alert?
    let bubble: Bubble?
    let callVisualizer: CallVisualizer?
    let secureMessagingWelcomeScreen: SecureConversationsWelcomeScreen?
    let secureMessagingConfirmationScreen: SecureConversationsConfirmationScreen?
    let snackBar: SnackBar?
    let webBrowserScreen: WebView?
    let entryWidget: EntryWidget?
    let isWhiteLabel: Bool?
}

extension RemoteConfiguration {
    final class GlobalColors: Codable {
        let primary: String?
        let secondary: String?
        let baseNormal: String?
        let baseLight: String?
        let baseDark: String?
        let baseShade: String?
        let systemNegative: String?
        let baseNeutral: String?

        init(
            primary: String?,
            secondary: String?,
            baseNormal: String?,
            baseLight: String?,
            baseDark: String?,
            baseShade: String?,
            systemNegative: String?,
            baseNeutral: String?
        ) {
            self.primary = primary
            self.secondary = secondary
            self.baseNormal = baseNormal
            self.baseLight = baseLight
            self.baseDark = baseDark
            self.baseShade = baseShade
            self.systemNegative = systemNegative
            self.baseNeutral = baseNeutral
        }
    }
}

extension RemoteConfiguration {
    final class Call: Codable {
        let background: Layer?
        let bottomText: Text?
        let buttonBar: ButtonBar?
        let duration: Text?
        let header: Header?
        let callOperator, topText: Text?
        let connect: EngagementStates?
        let visitorVideo: VisitorVideo?
        let snackBar: SnackBar?
        let mediaQualityIndicator: Text?

        enum CodingKeys: String, CodingKey {
            case background, bottomText, buttonBar, duration, header, connect
            case callOperator = "operator"
            case topText
            case visitorVideo
            case snackBar
            case mediaQualityIndicator
        }
    }

    final class VisitorVideo: Codable {
        let flipCameraButton: BarButtonStyle?
    }

    final class Alert: Codable {
        let title: Text?
        let titleImageColor: Color?
        let message: Text?
        let backgroundColor: Color?
        let closeButtonColor: Color?
        let linkButton: Button?
        let positiveButton: Button?
        let negativeButton: Button?
        let negativeNeutralButton: Button?
        let buttonAxis: Axis?
    }

    enum Axis: String, Codable {
        case horizontal
        case vertical
    }

    final class Bubble: Codable {
        let badge: Badge?
        let onHoldOverlay: OnHoldOverlayStyle?
        let userImage: UserImageStyle?
    }

    final class Badge: Codable {
        let background: Layer?
        let font: Font?
        let fontColor: Color?
    }

    final class OnHoldOverlayStyle: Codable {
        let backgroundColor: Color?
        let tintColor: Color?
    }

    final class UserImageStyle: Codable {
        let imageBackgroundColor: Color?
        let placeholderBackgroundColor: Color?
        let placeholderColor: Color?
    }

    final class Layer: Codable {
        let border: Color?
        let borderWidth: Double?
        let cornerRadius: Double?
        let color: Color?
    }

    final class Color: Codable {
        let type: ColorType
        let value: [String]
    }

    enum ColorType: String, Codable {
        case fill
        case gradient
    }

    final class Button: Codable {
        let background: Layer?
        let text: Text?
        let tintColor: Color?
        let shadow: Shadow?
    }

    final class Shadow: Codable {
        let color: Color?
        let offset: Double?
        let opacity, radius: Double?
    }

    final class Text: Codable {
        let alignment: Alignment?
        let background: Color?
        let font: Font?
        let foreground: Color?
    }

    enum Alignment: String, Codable {
        case center
        case leading
        case trailing

        var asNsTextAlignment: NSTextAlignment {
            switch self {
            case .center:
                return .center
            case .leading:
                return .left
            case .trailing:
                return .right
            }
        }
    }

    public final class Font: Codable {
        public let size: Double?
        public let style: FontStyle?

        init(size: Double?, style: FontStyle?) {
            self.size = size
            self.style = style
        }
    }

    public enum FontStyle: String, Codable {
        case bold, italic, regular, thin
    }

    final class ButtonBar: Codable {
        let chatButton, minimizeButton, muteButton, speakerButton: BarButtonStates?
        let videoButton: BarButtonStates?
        let badge: Badge?
    }

    final class BarButtonStates: Codable {
        let active: BarButtonStyle?
        let inactive: BarButtonStyle?
        let selected: BarButtonStyle?
    }

    final class BarButtonStyle: Codable {
        let background, imageColor: Color?
        let title: Text?
    }

    final class Survey: Codable {
        let title: Text?
        let layer: Layer?
        let submitButton: Button?
        let cancelButton: Button?
        let booleanQuestion: SurveyBooleanQuestion?
        let inputQuestion: SurveyInputQuestion?
        let scaleQuestion: SurveyScaleQuestion?
        let singleQuestion: SurveySingleQuestion?
    }

    final class SurveyBooleanQuestion: Codable {
        let optionButton: OptionButton?
        let title: Text?
    }

    final class OptionButton: Codable {
        let font: Font?
        let placeholder: Text?
        let highlightedLayer: Layer?
        let highlightedText: Text?
        let normalLayer: Layer?
        let normalText: Text?
        let selectedLayer: Layer?
        let selectedText: Text?
        let error: Text?
    }

    final class SurveyInputQuestion: Codable {
        let inputField: OptionButton?
        let title: Text?
    }

    final class SurveyScaleQuestion: Codable {
        let optionButton: OptionButton?
        let title: Text?
    }

    final class SurveySingleQuestion: Codable {
        let option: Text?
        let tintColor: Color?
        let title: Text?
        let error: Text?
    }

    final class EntryWidget: Codable {
        let background: Layer?
        let mediaTypeItems: MediaTypeItems?
        let errorTitle: Text?
        let errorMessage: Text?
        let errorButton: Button?
    }

    final class MediaTypeItems: Codable {
        let mediaTypeItem: MediaTypeItem?
        let dividerColor: Color?
    }

    final class MediaTypeItem: Codable {
        let background: Layer?
        let iconColor: Color?
        let title: Text?
        let message: Text?
        let loadingTintColor: Color?
    }

    final class SecureConversations: Codable {
        let unavailableStatusBackground: Layer?
        let unavailableStatusText: Text?
        let bottomBannerBackground: Layer?
        let bottomBannerText: Text?
        let bottomBannerDividerColor: Color?
        let topBannerBackground: Layer?
        let topBannerText: Text?
        let topBannerDividerColor: Color?
        let topBannerDropDownIconColor: Color?
        let mediaTypeItems: MediaTypeItems
    }
}
