import UIKit

public struct Theme {
    private typealias Strings = L10n

    public var primaryColor: UIColor {
        didSet { setPrimaryColor(primaryColor) }
    }
    public var chatStyle: ChatStyle

    public init() {
        primaryColor = Color.primary

        let chatHeaderStyle = HeaderStyle(backgroundColor: primaryColor,
                                          title: Strings.Chat.title,
                                          titleFont: Font.medium(20),
                                          titleFontColor: Color.headerTitle,
                                          backButtonColor: Color.headerButtonTint)
        chatStyle = ChatStyle(headerStyle: chatHeaderStyle,
                              backgroundColor: Color.background)

        setPrimaryColor(primaryColor)
    }

    private mutating func setPrimaryColor(_ color: UIColor) {
        chatStyle.headerStyle.backgroundColor = color
    }
}
