import UIKit

final class CustomCardContainerView: UIView {
    private let edgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 60)

    var willDisplayView: (() -> Void)?

    func addContentView(_ contentView: UIView) {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layoutInSuperview(insets: edgeInsets).activate()
    }
}
