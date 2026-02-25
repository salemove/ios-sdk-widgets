import SwiftUI
import GliaWidgets

struct SensitiveDataView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @SwiftUI.Environment(\.colorScheme) var appearance

    private let sensitiveText = """
        This screen emulates the integrator application screen with sensitive data.
        Be aware this screen should not be visible to the operator during Live Observation, but should be visible during screen sharing.
    """

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text(sensitiveText)
                    .setColor(appearance == .light ? .black : .white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .accessibilityIdentifier("sensitiveData_message")
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: dismissButton
                )
                ToolbarItem(
                    placement: .principal,
                    content: titleView
                )
            }
            .onAppear {
                Glia.sharedInstance.liveObservation.pause()
            }
            .onDisappear {
                Glia.sharedInstance.liveObservation.resume()
            }
        }
    }
}

extension SensitiveDataView {
    @ViewBuilder
    func titleView() -> some View {
        TitleView(title: "Sensitive Data")
            .setColor(appearance == .light ? .black : .white)
    }

    @MainActor
    func dismissButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
        }
        .accessibilityIdentifier("sensitiveData_close")
    }
}
