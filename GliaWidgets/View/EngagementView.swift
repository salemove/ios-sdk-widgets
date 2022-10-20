import UIKit

class EngagementView: View {
    let header: Header
    let connectView: ConnectView

    private let style: EngagementStyle
    private let environment: Environment

    init(
        with style: EngagementStyle,
        environment: Environment
    ) {
        self.style = style
        self.header = Header(with: style.header)
        self.environment = environment
        self.connectView = ConnectView(
            with: style.connect,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding
            )
        )
        super.init()
        setup()
        layout()
    }

    override func setup() {
        super.setup()

        switch style.backgroundColor {
        case .fill(color: let color):
            backgroundColor = color
        case .gradient(colors: let colors):
            makeGradientBackground(colors: colors).frame = bounds
        }
    }

    private func layout() {}
}

extension EngagementView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var timerProviding: FoundationBased.Timer.Providing
        var uiApplication: UIKitBased.UIApplication
    }
}
