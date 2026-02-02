import SwiftUI

struct EmbeddableWidgetContainer: View {
    @Binding var isExpanded: Bool
    let title: String
    let color: Color
    let action: () -> Void
    let onContainerReady: (UIView) -> Void
    let expandedHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .width(16)
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .setBackground(
                    shape: .rect(cornerRadius: 12, style: .continuous),
                    color: color.opacity(0.1)
                )
            }
            .buttonStyle(.plain)

            EmbeddedWidgetView(onViewReady: onContainerReady)
                .height(isExpanded ? expandedHeight : 0)
                .maxWidth()
                .padding(.top, isExpanded ? 8 : 0)
                .clipped()
                .animation(.easeInOut(duration: 0.2), value: isExpanded)
        }
    }
}
