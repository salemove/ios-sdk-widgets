import UIKit

public class Theme {
    private typealias Strings = L10n

    public let color: ThemeColor
    public let font: ThemeFont
    public lazy var chat: ChatStyle = { return chatStyle }()
    public lazy var call: CallStyle = { return callStyle }()
    public lazy var alert: AlertStyle = { return alertStyle }()
    public lazy var alertConfiguration: AlertConfiguration = { return alertConfigurationStyle }()
    public lazy var minimizedBubble: BubbleStyle = { return minimizedBubbleStyle }()

    public init(colorStyle: ThemeColorStyle = .default,
                fontStyle: ThemeFontStyle = .default) {
        self.color = colorStyle.color
        self.font = fontStyle.font
    }
}
