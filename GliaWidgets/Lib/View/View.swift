import UIKit

public class View: UIView {
    var currentOrientation: UIInterfaceOrientation {
        guard
            #available(iOS 13.0, *),
            let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        else {
            return UIApplication.shared.statusBarOrientation
        }

        return orientation
    }

    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
