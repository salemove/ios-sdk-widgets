import UIKit

extension Header {
    struct Props: Equatable {
        var title: String
        var effect: Effect
        var endButton: ActionButton.Props
        var backButton: HeaderButton.Props
        var closeButton: HeaderButton.Props
        var endScreenshareButton: HeaderButton.Props
        var style: HeaderStyle
    }
}
