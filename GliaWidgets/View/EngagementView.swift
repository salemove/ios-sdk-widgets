import UIKit

class EngagementView: BaseView {
    let header: Header

    private let style: EngagementStyle
    private let environment: Environment

    init(
        with style: EngagementStyle,
        environment: Environment
    ) {
        self.style = style
        self.header = Header(with: style.header)
        self.environment = environment
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
