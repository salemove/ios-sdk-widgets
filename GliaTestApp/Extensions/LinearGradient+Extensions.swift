import SwiftUI

extension LinearGradient {
    static var gliaPrimary: Self {
        .init(
            gradient: Gradient(
                colors: [
                    .init(red: 0.231, green: 0, blue: 0.568),
                    .init(red: 0.486, green: 0.098, blue: 0.866)
                ]
            ),
            startPoint: .bottom,
            endPoint: .top
        )
    }
}
