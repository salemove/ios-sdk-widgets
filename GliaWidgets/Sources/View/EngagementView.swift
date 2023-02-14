import UIKit

class EngagementView: BaseView {
    let header: Header
    let connectView: ConnectView

    private let style: EngagementStyle
    private let environment: Environment

    init(
        with style: EngagementStyle,
        layout: ConnectView.Layout,
        environment: Environment
    ) {
        self.style = style
        self.header = Header(
            props: .init(
                title: "",
                effect: .none,
                endButton: .init(style: style.header.endButton, title: style.header.endButton.title),
                backButton: .init(style: style.header.backButton),
                closeButton: .init(style: style.header.closeButton),
                endScreenshareButton: .init(style: style.header.endScreenShareButton),
                style: style.header
            )
        )
        self.environment = environment
        self.connectView = ConnectView(
            with: style.connect,
            layout: layout,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding
            )
        )
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func setup() {
        super.setup()

        switch style.backgroundColor {
        case .fill(color: let color):
            backgroundColor = color
        case .gradient(colors: let colors):
            makeGradientBackground(colors: colors)
        }
    }
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
