import UIKit

class View: UIView {
    var currentOrientation: UIInterfaceOrientation {
        guard
            #available(iOS 13.0, *),
            let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        else {
            return UIApplication.shared.statusBarOrientation
        }

        return orientation
    }

    init() {
        super.init(frame: .zero)
        setup()
        defineLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup() {}
    func defineLayout() {}
}
