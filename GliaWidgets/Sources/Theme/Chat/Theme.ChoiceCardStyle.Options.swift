import Foundation

public extension Theme.ChoiceCardStyle {
    struct Option {
        /// Style of an option in an active state - choice card has not been answered by the visitor yet.
        public var normal: Theme.Button
        /// Style of an option in a selected state - choice card has already been answered by the visitor.
        public var selected: Theme.Button
        /// Style of an option in a disabled state - choice card has already been answered by the visitor 
        /// or the choice card became inactive (e.g. engagement ended).
        public var disabled: Theme.Button

        /// - Parameters:
        ///   - normal: Style of an option in an active state - choice card has not been answered by the visitor yet.
        ///   - selected: Style of an option in a selected state - choice card has already been answered by the visitor.
        ///   - disabled: Style of an option in a disabled state - choice card has already been answered by the visitor 
        ///   or the choice card became inactive (e.g. engagement ended).
        ///
        public init(
            normal: Theme.Button,
            selected: Theme.Button,
            disabled: Theme.Button
        ) {
            self.normal = normal
            self.selected = selected
            self.disabled = disabled
        }
    }
}
