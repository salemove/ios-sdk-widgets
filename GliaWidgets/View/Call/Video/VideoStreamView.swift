import UIKit
import SalemoveSDK

class VideoStreamView: View {
    enum Kind {
        case local
        case remote
    }

    private var streamView: StreamView? {
        get { return subviews.first as? StreamView }
        set {
            streamView?.removeFromSuperview()

            if let streamView = newValue {
                addSubview(streamView)
                streamView.autoPinEdgesToSuperviewEdges()
            }
        }
    }
    private let kind: Kind

    init(_ kind: Kind) {
        self.kind = kind
        super.init()
        setup()
        layout()
    }

    private func setup() {
        clipsToBounds = true

        if kind == .local {
            layer.cornerRadius = 6
        }
    }

    private func layout() {}
}
