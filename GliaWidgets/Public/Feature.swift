import Foundation

/// SDK features
public struct Features: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Bubble that is shown in engagement time outside of engagement view.
    public static let bubbleView = Self(rawValue: 1 << 0)
    public static let all: Self = [.bubbleView]
}
