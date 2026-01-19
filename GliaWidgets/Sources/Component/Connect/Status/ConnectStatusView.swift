import SwiftUI

struct ConnectStatusView: View {
    let firstText: String?
    let secondText: String?
    let connectStyle: ConnectStatusStyle
    let secondLineStyle: SecondLineStyle
    private let durationIdentifier: String = "call_duration_label"

    var body: some View {
        VStack(spacing: 8) {
            firstTextView()
            secondLineView()
        }
        .maxWidth()
    }

    @ViewBuilder
    func firstTextView() -> some View {
        if let firstText, !firstText.isEmpty {
            Text(firstText)
                .setFont(connectStyle.firstTextFont, textStyle: connectStyle.firstTextStyle)
                .setColor(connectStyle.firstTextFontColor)
                .multilineTextAlignment(.center)
                .accessibilityHint(connectStyle.accessibility.firstTextHint)
        }
    }

    @ViewBuilder
    private func secondLineView() -> some View {
        if let secondText, !secondText.isEmpty {
            switch secondLineStyle {
            case let .connect(style):
                Text(secondText)
                    .setFont(style.secondTextFont, textStyle: connectStyle.secondTextStyle)
                    .setColor(style.secondTextFontColor)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(durationIdentifier)
                    .accessibilityHint(style.accessibility.secondTextHint ?? "")
            case let .duration(callStyle, hint):
                Text(secondText)
                    .setFont(callStyle.durationFont, textStyle: callStyle.durationTextStyle)
                    .setColor(callStyle.durationColor)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(durationIdentifier)
                    .accessibilityHint(hint ?? "")
            }
        }
    }
}

extension ConnectStatusView {
    enum SecondLineStyle: Equatable {
        case connect(ConnectStatusStyle)
        case duration(callStyle: CallStyle, hint: String? = nil)
    }
}
