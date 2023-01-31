import Foundation

extension Optional {
    /// Unwraps wrapped value and passes it to block if exists.
    func unwrap(_ block: (Wrapped) -> Void) {
        switch self {
        case .some(let value):
            block(value)
        case .none:
            return
        }
    }
}
