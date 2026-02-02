import Foundation
import SwiftUI

extension View {
    func setColor(_ color: Color) -> some View {
        return self
            .foregroundStyle(color)
    }

    func setColor<S1, S2>(_ primary: S1, _ secondary: S2) -> some View where S1 : ShapeStyle, S2 : ShapeStyle {
        return self
            .foregroundStyle(primary, secondary)
    }

    func setColor<S1>(_ primary: S1, _ secondary: Color) -> some View where S1 : ShapeStyle {
        return self
            .foregroundStyle(primary, secondary)
    }

    func setColor<S1>(_ primary: S1) -> some View where S1 : ShapeStyle {
        return self
            .foregroundStyle(primary)
    }

    func setBackground(color: Color) -> some View {
        return self
            .background(color)
    }

    func setBackground(material: Material) -> some View {
        return self
            .background(material)
    }

    func setBackground(shape: some Shape, color: Color) -> some View {
        return self
            .background(shape.fill(color))
    }

    func setBackground(shape: some Shape, color: some ShapeStyle) -> some View {
        return self
            .background(shape.fill(color))
    }

    func fit() -> some View {
        return self
            .aspectRatio(contentMode: .fit)
    }

    func fill() -> some View {
        return self
            .aspectRatio(contentMode: .fill)
    }

    func maxWidth(alignment: Alignment = .center) -> some View {
        return self
            .frame(maxWidth: .infinity, alignment: alignment)
    }

    func maxSize(alignment: Alignment = .center) -> some View {
        return self
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }

    func maxHeight(alignment: Alignment = .center) -> some View {
        return self
            .frame(maxHeight: .infinity, alignment: alignment)
    }

    func minHeight(_ height: CGFloat, alignment: Alignment = .center) -> some View {
        return self
            .frame(minHeight: height, alignment: alignment)
    }

    func minWidth(_ width: CGFloat, alignment: Alignment = .center) -> some View {
        return self
            .frame(minWidth: width, alignment: alignment)
    }

    func height(_ height: CGFloat) -> some View {
        return self
            .frame(height: height)
    }

    func width(_ width: CGFloat) -> some View {
        return self
            .frame(width: width)
    }

    func setSymbol(_ variant: SymbolVariants, _ renderMode: SymbolRenderingMode = .monochrome) -> some View {
        self
            .symbolVariant(variant)
            .symbolRenderingMode(renderMode)
    }

    func setBorder<S: InsettableShape, T: ShapeStyle>(
        shape: S,
        color: T,
        lineWidth: CGFloat = 2
    ) -> some View {
        self.overlay(
            shape.stroke(color, lineWidth: lineWidth)
        )
    }

    func setBorder<S: InsettableShape>(
        shape: S,
        color: Color,
        lineWidth: CGFloat = 1
    ) -> some View {
        self.overlay(
            shape.stroke(color, lineWidth: lineWidth)
        )
    }
}
