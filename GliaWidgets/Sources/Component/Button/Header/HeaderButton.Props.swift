import Foundation

extension HeaderButton {
    struct Props {
        var tap: Cmd
        var style: HeaderButtonStyle
        var size: CGSize

        init(
            tap: Cmd = .nop,
            style: HeaderButtonStyle = .init(image: .init(), color: .black),
            size: CGSize = CGSize(width: 30, height: 30)
        ) {
            self.tap = tap
            self.style = style
            self.size = size
        }
    }
}
