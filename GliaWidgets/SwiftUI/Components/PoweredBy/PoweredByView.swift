import SwiftUI

struct PoweredByView: View {
    let style: PoweredByStyle
    let containerHeight: CGFloat
    let color: UIColor = Color.baseShade
    @ScaledMetric var scale: CGFloat = 1

    init(
        style: PoweredByStyle,
        containerHeight: CGFloat
    ) {
        self.style = style
        self.containerHeight = containerHeight
    }

    var body: some View {
        HStack(spacing: 5) {
            Text(Localization.General.powered)
                .setColor(color.swiftUIColor())
                .opacity(0.5)
                .font(.convert(style.font))
                .accessibilityLabel("Powered By Glia")
            Asset.gliaLogo.image.asSwiftUIImage()
                .resizable()
                .fit()
                .height(20 * scale)
                .setColor(color.swiftUIColor())
                .accessibilityHidden(true)
        }
        .height(containerHeight)
    }
}
