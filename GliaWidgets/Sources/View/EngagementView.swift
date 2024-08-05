import UIKit

class EngagementView: BaseView {
    let header: Header
    let connectView: ConnectView

    private let style: EngagementStyle
    private let environment: Environment

    init(
        with style: EngagementStyle,
        layout: ConnectView.Layout,
        environment: Environment,
        headerProps: Header.Props
    ) {
        self.style = style
        self.header = Header(props: headerProps)
        self.environment = environment
        self.connectView = ConnectView(
            with: style.connect,
            layout: layout,
            environment: .create(with: environment)
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
