import UIKit
import SalemoveSDK

class VideoStreamView: View {
    enum Kind {
        case local
        case remote
    }

    weak var streamView: StreamView? {
        didSet {
            replace(oldStreamView: oldValue, with: streamView)
        }
    }

    private let kind: Kind

    init(_ kind: Kind) {
        self.kind = kind
        super.init()
        setup()
    }

    private func setup() {
        clipsToBounds = true
        layer.cornerRadius = kind == .local ? 6.0 : 0.0
    }

    private func replace(
        oldStreamView: StreamView?,
        with streamView: StreamView?
    ) {
        oldStreamView?.removeFromSuperview()
        guard let streamView = streamView else { return }
        streamView.scale = .aspectFill
        addSubview(streamView)
        streamView.autoPinEdgesToSuperviewEdges()
        streamView.layoutIfNeeded()
    }
}
