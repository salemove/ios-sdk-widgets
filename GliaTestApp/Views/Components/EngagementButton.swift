import SwiftUI

struct EngagementButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .setSymbol(.fill)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .maxWidth()
            .height(120)
            .setColor(.white)
            .background(
                LinearGradient.gliaPrimary,
                in: .rect(cornerRadius: 16, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}
