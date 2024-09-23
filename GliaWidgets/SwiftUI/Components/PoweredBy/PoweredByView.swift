import SwiftUI

struct PoweredByView: View {
    let style: PoweredByStyle
    let containerHeight: CGFloat
    let color: UIColor = Color.baseShade

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
            Asset.gliaLogo.image.asSwiftUIImage()
                .resizable()
                .fit()
                .height(20)
                .setColor(color.swiftUIColor())
        }
        .height(containerHeight)
    }
}
