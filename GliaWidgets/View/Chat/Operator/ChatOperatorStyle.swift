import UIKit

public struct ChatOperatorStyle {
    public var color: UIColor
    public var animationColor: UIColor
    public var waiting: ChatOperatorWaitingStyle
    public var connecting: ChatOperatorConnectingStyle
    public var connected: ChatOperatorConnectedStyle

    public init(color: UIColor,
                animationColor: UIColor,
                waiting: ChatOperatorWaitingStyle,
                connecting: ChatOperatorConnectingStyle,
                connected: ChatOperatorConnectedStyle) {
        self.color = color
        self.animationColor = animationColor
        self.waiting = waiting
        self.connecting = connecting
        self.connected = connected
    }
}

public struct ChatOperatorWaitingStyle {
    public var titleText: String?
    public var titleTextFont: UIFont
    public var titleTextFontColor: UIColor
    public var infoText: String?
    public var infoTextFont: UIFont
    public var infoTextFontColor: UIColor

    public init(titleText: String?,
                titleTextFont: UIFont,
                titleTextFontColor: UIColor,
                infoText: String?,
                infoTextFont: UIFont,
                infoTextFontColor: UIColor) {
        self.titleText = titleText
        self.titleTextFont = titleTextFont
        self.titleTextFontColor = titleTextFontColor
        self.infoText = infoText
        self.infoTextFont = infoTextFont
        self.infoTextFontColor = infoTextFontColor
    }
}

public struct ChatOperatorConnectingStyle {
    public var text: String?
    public var textFont: UIFont
    public var textFontColor: UIColor
    public var counterFont: UIFont
    public var counterFontColor: UIColor

    public init(text: String?,
                textFont: UIFont,
                textFontColor: UIColor,
                counterFont: UIFont,
                counterFontColor: UIColor) {
        self.text = text
        self.textFont = textFont
        self.textFontColor = textFontColor
        self.counterFont = counterFont
        self.counterFontColor = counterFontColor
    }
}

public struct ChatOperatorConnectedStyle {
    public var text: String?
    public var textFont: UIFont
    public var textFontColor: UIColor

    public init(text: String?,
                textFont: UIFont,
                textFontColor: UIColor) {
        self.text = text
        self.textFont = textFont
        self.textFontColor = textFontColor
    }
}
