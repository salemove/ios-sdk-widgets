import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var style: Style = .standard
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: style == .standard ? 16 : 15, weight: .semibold))

                Text(title)
                    .font(.system(size: style == .standard ? 16 : 15, weight: .semibold))
            }
            .maxWidth()
            .height(style == .standard ? 50 : 44)
            .setColor(color)
            .setBackground(
                shape: .rect(cornerRadius: 16, style: .continuous),
                color: color.opacity(0.1)
            )
            .setBorder(
                shape: .rect(cornerRadius: 16, style: .continuous),
                color: color.opacity(0.3)
            )
        }
        .buttonStyle(.plain)
    }
}

extension ActionButton {
    enum Style {
        case standard
        case compact
    }
}
