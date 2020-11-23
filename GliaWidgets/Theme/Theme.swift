import UIKit

public struct Theme {
    private typealias Strings = L10n

    public let primaryColor: UIColor
    public let secondaryColor: UIColor
    public let baseNormalColor: UIColor
    public let baseLightColor: UIColor
    public let baseDarkColor: UIColor
    public let baseShadeColor: UIColor
    public let backgroundColor: UIColor
    public let systemNegativeColor: UIColor
    public var chat: ChatStyle

    public init(primaryColor: UIColor = Color.primary,
                secondaryColor: UIColor = Color.secondary,
                baseNormalColor: UIColor = Color.baseNormal,
                baseLightColor: UIColor = Color.baseLight,
                baseDarkColor: UIColor = Color.baseDark,
                baseShadeColor: UIColor = Color.baseShade,
                backgroundColor: UIColor = Color.background,
                systemNegativeColor: UIColor = Color.systemNegative) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.baseNormalColor = baseNormalColor
        self.baseLightColor = baseLightColor
        self.baseDarkColor = baseDarkColor
        self.baseShadeColor = baseShadeColor
        self.backgroundColor = backgroundColor
        self.systemNegativeColor = systemNegativeColor

        let chatHeaderStyle = HeaderStyle(title: Strings.Chat.title,
                                          titleFont: Font.medium(20),
                                          titleColor: baseLightColor,
                                          leftItemColor: baseLightColor,
                                          rightItemColor: baseLightColor,
                                          backgroundColor: primaryColor)
        chat = ChatStyle(headerStyle: chatHeaderStyle,
                         backgroundColor: backgroundColor)
    }
}
