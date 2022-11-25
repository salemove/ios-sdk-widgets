import SwiftUI

struct EngagementButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline.weight(.regular))
            .padding(.vertical, 12)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(Colors.gliaPurple)
            .clipShape(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .shadow(color: Colors.shadow, radius: 16, x: 0, y: 0)
            .padding(.horizontal, 32)
    }
}
