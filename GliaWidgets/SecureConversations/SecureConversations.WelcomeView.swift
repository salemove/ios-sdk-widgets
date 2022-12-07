import Foundation
import UIKit

extension SecureConversations {
    final class WelcomeView: View {
        private let style: SecureConversations.WelcomeStyle
        let header: Header

        init(with style: SecureConversations.WelcomeStyle) {
            self.style = style
            self.header = Header(with: style.header)

            super.init()
        }

        override func setup() {
            super.setup()

            header.title = style.title
            backgroundColor = style.backgroundColor
        }

        override func defineLayout() {
            super.defineLayout()
            addSubview(header)
            header.autoPinEdgesToSuperviewEdges(
                with: .zero,
                excludingEdge: .bottom
            )
        }
    }
}
