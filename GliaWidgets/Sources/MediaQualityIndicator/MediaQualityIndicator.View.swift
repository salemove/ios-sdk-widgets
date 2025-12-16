import SwiftUI

struct MediaQualityIndicatorView: View {
    let style: MediaQualityIndicatorStyle

    var body: some View {
        Text(style.text)
            .setFont(style.font)
            .setColor(style.foreground)
            .maxWidth()
            .padding(.vertical, 6)
            .applyColorTypeBackground(style.background)
            .accessibilityIdentifier("connection_banner")
            .accessibilityLabel(style.accessibility.label)
    }
}
