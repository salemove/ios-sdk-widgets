//
//  Glia.Hacko.Config.swift
//  GliaWidgets
//
//  Created by Yurii Dukhovnyi on 17.06.2022.
//

import UIKit

extension Glia {

    public struct RemoteConfig: Decodable {
        let navigationBar: NavigationBar
        let layer: Layer
        let separator: Layer
        let textField: TextField
        let visitorMessage: MessageBalloon
        let operatorMessage: MessageBalloon
        let welcomeView: WelcomeView

        public struct NavigationBar: Decodable {
            let layer: Layer
            let title: Text
        }

        public struct TextField: Decodable {
            let text: Text
            let tintColor: UIColor
            let layer: Layer

            enum CodingKeys: String, CodingKey {
                case text, tintColor, layer
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.text = try container.decode(Text.self, forKey: .text)
                self.layer = try container.decode(Layer.self, forKey: .layer)
                self.tintColor = UIColor(hex: try container.decode(String.self, forKey: .tintColor))
            }
        }

        public struct Text: Decodable {
            let foreground: UIColor
            let fontSize: CGFloat

            enum CodingKeys: String, CodingKey {
                case foreground, fontSize
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.foreground = UIColor(hex: try container.decode(String.self, forKey: .foreground))
                self.fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
            }
        }

        public struct Layer: Decodable {
            let background: UIColor
            var border: UIColor?
            let borderWidth: CGFloat
            let cornerRadius: CGFloat

            enum CodingKeys: String, CodingKey {
                case background, border, borderWidth, cornerRadius
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.background = UIColor(hex: try container.decode(String.self, forKey: .background))
                self.border = try container.decodeIfPresent(String.self, forKey: .border).map { UIColor(hex: $0) }
                self.borderWidth = try container.decode(CGFloat.self, forKey: .borderWidth)
                self.cornerRadius = try container.decode(CGFloat.self, forKey: .cornerRadius)
            }
        }

        public struct MessageBalloon: Decodable {
            let text: Text
            let layer: Layer
        }

        struct WelcomeView: Decodable {
            let title: Text
            let titleValue: String
            let description: Text
            let descriptionValue: String
            let tintColor: UIColor

            enum CodingKeys: String, CodingKey {
                case title, titleValue, description, descriptionValue, tintColor
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.title = try container.decode(Text.self, forKey: .title)
                self.titleValue = try container.decode(String.self, forKey: .titleValue)
                self.description = try container.decode(Text.self, forKey: .description)
                self.descriptionValue = try container.decode(String.self, forKey: .descriptionValue)
                self.tintColor = try UIColor(hex: container.decode(String.self, forKey: .tintColor))
            }
        }
    }
}

private extension UIColor {

    convenience init(hex: String) {
        let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
        let ui64 = UInt64(hexString, radix: 16)
        let value = ui64 != nil ? Int(ui64!) : 0
        // #RRGGBB
        var components = (
            R: CGFloat((value >> 16) & 0xff) / 255,
            G: CGFloat((value >> 08) & 0xff) / 255,
            B: CGFloat((value >> 00) & 0xff) / 255,
            a: CGFloat(1)
        )
        if String(hexString).count == 8 {
            // #RRGGBBAA
            components = (
                R: CGFloat((value >> 24) & 0xff) / 255,
                G: CGFloat((value >> 16) & 0xff) / 255,
                B: CGFloat((value >> 08) & 0xff) / 255,
                a: CGFloat((value >> 00) & 0xff) / 255
            )
        }
        self.init(red: components.R, green: components.G, blue: components.B, alpha: components.a)
    }

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
