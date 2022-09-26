import Foundation

public extension MessageRenderer {
    /// Message renderer to render HTML-string metadata
    static let webRenderer = Self { message in
        guard let htmlMetadata = try? message.metadata?.decode(HtmlMetadata.self) else { return nil }
        return WebMessageCardView(
            policyProvider: .customResponseCard,
            message: message,
            metadata: htmlMetadata
        )
    }
}
