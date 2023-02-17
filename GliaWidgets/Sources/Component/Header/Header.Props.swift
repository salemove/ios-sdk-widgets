import UIKit

extension Header {
    struct Props: Equatable {
        let title: String
        let effect: Effect
        let endButton: ActionButton.Props
        let backButton: HeaderButton.Props
        let closeButton: HeaderButton.Props
        let endScreenshareButton: HeaderButton.Props
        let style: HeaderStyle
    }
}
