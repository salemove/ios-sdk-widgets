import UIKit

public struct ThemeColor {
    public let primary: UIColor
    public let secondary: UIColor
    public let baseNormal: UIColor
    public let baseLight: UIColor
    public let baseDark: UIColor
    public let baseShade: UIColor
    public let background: UIColor
    public let systemNegative: UIColor

    public init(primary: UIColor? = nil,
                secondary: UIColor? = nil,
                baseNormal: UIColor? = nil,
                baseLight: UIColor? = nil,
                baseDark: UIColor? = nil,
                baseShade: UIColor? = nil,
                background: UIColor? = nil,
                systemNegative: UIColor? = nil) {
        self.primary = primary ?? Color.primary
        self.secondary = secondary ?? Color.secondary
        self.baseNormal = baseNormal ?? Color.baseNormal
        self.baseLight = baseLight ?? Color.baseLight
        self.baseDark = baseDark ?? Color.baseDark
        self.baseShade = baseShade ?? Color.baseShade
        self.background = background ?? Color.background
        self.systemNegative = systemNegative ?? Color.systemNegative
    }
}
