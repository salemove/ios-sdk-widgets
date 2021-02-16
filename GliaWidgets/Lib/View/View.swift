import UIKit

public class View: UIView {
    var currentOrientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    var isLandscape: Bool {
        return [.landscapeLeft, .landscapeRight].contains(currentOrientation)
    }

    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
