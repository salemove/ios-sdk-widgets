import UIKit

public class View: UIView {
    var currentOrientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }

    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
