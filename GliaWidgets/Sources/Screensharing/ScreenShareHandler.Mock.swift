import Foundation

#if DEBUG
extension ScreenShareHandler {
    static let mock = Self(
        status: { .init(with: .stopped) },
        updateState: { _ in },
        stop: { _ in },
        cleanUp: {}
    )
}
#endif
