import UIKit

public extension RemoteConfiguration {
    /// Provides assets for remote configuration.
    struct AssetsBuilder {
        /// The font builder provides the UIFont instance for appropriate Font configururation structure.
        public var fontBuilder: (RemoteConfiguration.Font?) -> UIFont?

        /// The default implementation of the AssetsBuilder.
        /// Transforms `RemoteConfiguration.Font` to SF font family `UIFont`
        public static let standard: Self = .init(
            fontBuilder: { font in
                guard
                    let fontSize = font?.size,
                    let fontStyle = font?.style
                else {
                    return nil
                }
                let weight = UIFont.Weight(fontStyle: fontStyle)

                let font = fontStyle == .italic ? UIFont.italicFont(weight:size:) : UIFont.font(weight:size:)
                return font(weight, fontSize)
            }
        )

        /// Initilizes the assets builder with font-building closure.
        ///
        /// - Parameter fontBuilder: Closure that provides the UIFont instance for appropriate Font configururation structure.
        ///
        public init(fontBuilder: @escaping (RemoteConfiguration.Font?) -> UIFont?) {
            self.fontBuilder = fontBuilder
        }
    }
}
