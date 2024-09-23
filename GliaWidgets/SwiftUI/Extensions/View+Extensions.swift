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
}
