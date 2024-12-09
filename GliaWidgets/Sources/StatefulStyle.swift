/// Stateful style to represent enabled and disabled states of the component.
/// Simplifies access to underlying properties of the generic `State` type.
@dynamicMemberLookup
enum StatefulStyle<State> {
    /// Enabled state.
    case enabled(State)
    /// Disabled state.
    case disabled(State)

    subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
        get {
            switch self {
            case let .enabled(style):
                return style[keyPath: keyPath]
            case let .disabled(style):
                return style[keyPath: keyPath]
            }
        }

        set (newValue) {
            switch self {
            case var .enabled(style):
                style[keyPath: keyPath] = newValue
                self = .enabled(style)
            case var .disabled(style):
                style[keyPath: keyPath] = newValue
                self = .disabled(style)
            }
        }
    }
}

extension StatefulStyle: Equatable where State: Equatable {}
