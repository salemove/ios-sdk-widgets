import SwiftUI

struct Background: View {
    let colorType: ColorType

    init(_ colorType: ColorType) {
        self.colorType = colorType
    }
    var body: some View {
        switch colorType {
        case .fill(let color):
            SwiftUI.Color(color)
        case .gradient(let colors):
            let convertedColors = colors
                .map { UIColor(cgColor: $0) }
                .map { SwiftUI.Color($0) }
            LinearGradient(
                colors: convertedColors,
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
