import SwiftUI

struct OnHoldOverlay: View {
    let style: OnHoldOverlayStyle
    private let blurOpacity: CGFloat = 0.5
    private let extraBlurRadius: CGFloat = 0.5

    var body: some View {
        ZStack {
            Background(style.backgroundColor)
            blurView()
            tintedIcon()
        }
        .maxSize()
        .clipShape(.circle)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    func blurView() -> some View {
        Rectangle()
            .fill(.regularMaterial)
            .opacity(blurOpacity)
            .blur(radius: extraBlurRadius)
            .allowsHitTesting(false)
    }

    @ViewBuilder
    func tintedIcon() -> some View {
        SwiftUI.Image(uiImage: style.image)
            .renderingMode(.template)
            .resizable()
            .fit()
            .applyColorTypeForeground(style.imageColor)
            .width(style.imageSize.width)
            .height(style.imageSize.height)
    }
}
