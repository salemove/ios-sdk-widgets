import UIKit

public struct ThemeColor {
    public var primary: UIColor
    public var secondary: UIColor
    public var baseNormal: UIColor
    public var baseLight: UIColor
    public var baseDark: UIColor
    public var baseShade: UIColor
    public var background: UIColor
    public var systemNegative: UIColor

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
