import SwiftUI

extension SwiftUI.View {
    func maxWidth(alignment: Alignment = .center) -> some View {
        return self
            .frame(
                maxWidth: .infinity,
                alignment: alignment
            )
    }

    func maxSize(alignment: Alignment = .center) -> some View {
        return self
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: alignment
            )
    }

    func maxHeight(alignment: Alignment = .center) -> some View {
        return self
            .frame(
                maxHeight: .infinity,
                alignment: alignment
            )
    }

    func fit() -> some View {
        return self
            .aspectRatio(contentMode: .fit)
    }

    func fill() -> some View {
        return self
            .aspectRatio(contentMode: .fill)
    }

    func height(_ value: CGFloat) -> some View {
        return self
            .frame(height: value)
    }

    func width(_ value: CGFloat) -> some View {
        return self
            .frame(width: value)
    }

    func setColor(_ color: SwiftUI.Color) -> some View {
        return self
            .foregroundColor(color)
    }

    func setColor(_ color: UIColor) -> some View {
        return self
            .foregroundColor(color.swiftUIColor())
    }

    func setFont(_ font: UIFont, textStyle: UIFont.TextStyle = .body) -> some View {
        return self
            .font(.convert(font, textStyle: textStyle))
    }

    @ViewBuilder
    func applyColorTypeForeground(_ colorType: ColorType) -> some View {
        switch colorType {
        case let .fill(color):
            self.setColor(color)
        case let .gradient(colors):
            let convertedColors = colors.map { $0.swiftUIColor() }
            if #available(iOS 15, *) {
                self.foregroundStyle(.linearGradient(
                    colors: convertedColors,
                    startPoint: .top,
                    endPoint: .bottom
                ))
            } else {
                let gradient = LinearGradient(
                    gradient: Gradient(colors: convertedColors),
                    startPoint: .top,
                    endPoint: .bottom
                )
                self
                    .overlay(gradient)
                    .mask(self)
            }
        }
    }

    @ViewBuilder
    func applyColorTypeBackground(_ colorType: ColorType) -> some View {
        switch colorType {
        case let .fill(color):
            self.background(color.swiftUIColor())
        case let .gradient(colors):
            let convertedColors = colors.map { $0.swiftUIColor() }
            self.background(
                LinearGradient(
                    colors: convertedColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    @ViewBuilder
    func redactedPlaceholder(
        _ colorType: ColorType,
        font: UIFont? = nil,
        cornerRadius: CGFloat = 2
    ) -> some View {
        let padding: CGFloat = if let font = font {
            font.pointSize * 0.22
        } else {
            0
        }

        self
            .opacity(0)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .setColor(Color.baseShade)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, padding)
            )
            .redacted(reason: .placeholder)
    }
}
