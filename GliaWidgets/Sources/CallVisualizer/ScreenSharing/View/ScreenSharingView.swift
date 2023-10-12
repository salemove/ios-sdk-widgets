import SwiftUI

extension CallVisualizer {
    struct ScreenSharingView: View {
        @ObservedObject var model: Model

        var body: some View {
            ZStack {
                Background(model.style.backgroundColor)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    HeaderSwiftUI(model: model.makeHeaderModel())
                    VStack(spacing: 16) {
                        mainLabel
                        endScreenShareButton
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }.edgesIgnoringSafeArea(.top)
            }
        }
    }
}

extension CallVisualizer.ScreenSharingView {
    var mainLabel: some View {
        Text(model.style.messageText)
            .font(.convert(model.style.messageTextFont))
            .foregroundColor(SwiftUI.Color(model.style.messageTextColor))
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .migrationAccessibilityIdentifier("end_screen_sharing_message")
    }

    var endScreenShareButton: some View {
        SwiftUI.Button(action: {
            model.event(.endScreenShareTapped)
        }, label: {
            HStack(spacing: 8) {
                SwiftUI.Image(uiImage: model.style.buttonIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                    .foregroundColor(SwiftUI.Color(model.style.buttonStyle.titleColor))
                Text(model.style.buttonStyle.title)
                    .font(.convert(model.style.buttonStyle.titleFont))
                    .foregroundColor(SwiftUI.Color(model.style.buttonStyle.titleColor))
                    .lineLimit(nil)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, minHeight: 40, idealHeight: 40)
            .background(Background(model.style.buttonStyle.backgroundColor))
            .cornerRadius(4)
            .padding(.horizontal, 60)
        })
        .migrationAccessibilityIdentifier("end_screen_sharing_button")
        .migrationAccessibilityLabel(Localization.ScreenSharing.VisitorScreen.End.title)
        .migrationAccessibilityHint(Localization.ScreenSharing.VisitorScreen.End.Accessibility.hint)
    }
}
