import Foundation
import UIKit

extension Theme {
    /// Text style.
    public struct Text {
        /// Foreground hex color.
        public var color: String
        /// Font.
        public var font: UIFont

        /// Text aligmment.
        public var alignment: NSTextAlignment

        /// Initializes `Text` style instance.
        public init(
            color: String,
            font: UIFont,
            alignment: NSTextAlignment = .center
        ) {
            self.color = color
            self.font = font
            self.alignment = alignment
        }

        /// Apply text from remote configuration
        mutating func applyTextConfiguration(_ text: RemoteConfiguration.Text?) {
            text?.alignment.map { alignment in
                switch alignment {
                case .center:
                    self.alignment = .center
                case .leading:
                    self.alignment = .left
                case .trailing:
                    self.alignment = .right
                }
            }

            text?.background.map { _ in

            /// The logic for normal text background has not been implemented

            }

            UIFont.convertToFont(font: text?.font).map {
                font = $0
            }

            text?.foreground?.type.map { foregroundType in
                switch foregroundType {
                case .fill:
                    text?.foreground?.value.map {
                        self.color = $0[0]
                    }
                case .gradient:

                /// The logic for gradient has not been implemented

                    break
                }
            }
        }
    }
}
