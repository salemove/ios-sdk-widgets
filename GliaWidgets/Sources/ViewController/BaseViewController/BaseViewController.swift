import UIKit

class BaseViewController<T: BaseView>: UIViewController {
    var contentView: T {
        // swiftlint:disable force_cast
        view as! T
        // swiftlint:enable force_cast
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = T()
    }
}
