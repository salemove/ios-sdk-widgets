import UIKit
import SalemoveSDK

class VideoStreamView: View {
    enum Kind {
        case local
        case remote
    }

    var streamView: StreamView? {
        get { return subviews.first as? StreamView }
        set {
            guard newValue != streamView else { return }
            streamView?.removeFromSuperview()
            if let streamView = newValue {
                streamView.scale = .aspectFill
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
        layer.cornerRadius = kind == .local ? 6.0 : 0.0
    }

    private func layout() {}
}
