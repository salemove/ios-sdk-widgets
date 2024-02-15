import UIKit

extension ThemeColor {
    mutating func apply(
        configuration: RemoteConfiguration.GlobalColors?
    ) {
        configuration?.primary.unwrap {
            primary = UIColor(hex: $0)
        }

        configuration?.secondary.unwrap {
            secondary = UIColor(hex: $0)
        }

        configuration?.baseNormal.unwrap {
            baseNormal = UIColor(hex: $0)
        }

        configuration?.baseLight.unwrap {
            baseLight = UIColor(hex: $0)
        }

        configuration?.baseDark.unwrap {
            baseDark = UIColor(hex: $0)
        }

        configuration?.baseShade.unwrap {
            baseShade = UIColor(hex: $0)
        }

        configuration?.systemNegative.unwrap {
            systemNegative = UIColor(hex: $0)
        }

        configuration?.baseNeutral.unwrap {
            baseNeutral = UIColor(hex: $0)
        }
    }
}
