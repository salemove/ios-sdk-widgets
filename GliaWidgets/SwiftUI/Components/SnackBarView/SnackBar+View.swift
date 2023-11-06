import Combine
import SwiftUI

extension SnackBar {
    struct ContentView: View {
        enum ViewState { case appear(String), disappear }
        let publisher: AnyPublisher<ViewState, Never>

        @State private var text = ""
        @State private var currentOffset: CGFloat = 300
        let style: Theme.SnackBarStyle
        var offset: CGFloat = 0

        init(
            style: Theme.SnackBarStyle,
            publisher: AnyPublisher<ViewState, Never>
        ) {
            self.style = style
            self.publisher = publisher
        }

        var body: some View {
            Text(text)
                .padding()
                .frame(maxWidth: .infinity)
                .background(SwiftUI.Color(style.background))
                .cornerRadius(4)
                .foregroundColor(SwiftUI.Color(style.textColor))
                .font(.convert(style.textFont))
                .padding()
                .offset(y: currentOffset)
                .onReceive(publisher) { newState in
                    switch newState {
                    case .appear(let text):
                        self.text = text
                        withAnimation {
                            self.currentOffset = offset
                        }
                    case .disappear:
                        withAnimation {
                            self.currentOffset = 300
                        }
                    }
                }
        }
    }

}

struct SnackBarContentView_Previews: PreviewProvider {
    static var previews: some View {
        SnackBar.ContentView(
            style: .defaultStyle,
            publisher: CurrentValueSubject<SnackBar.ContentView.ViewState, Never>(
                .appear("SnackBar.ContentView.Previews")
            ).eraseToAnyPublisher()
        )
    }
}

extension Theme.SnackBarStyle {
    static let defaultStyle: Self = .init(
        background: .init(hex: "#2C0735"),
        textColor: .init(hex: "#FFFFFF"),
        textFont: UIFont.systemFont(ofSize: 17, weight: .regular),
        accessibility: .init(isFontScalingEnabled: true)
    )
}
