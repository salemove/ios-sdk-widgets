import UIKit
import PureLayout

final class AlertIllustrationItemView: UIView {
    private let imageView = UIImageView()
    private let image: UIImage

    init(image: UIImage) {
        self.image = image

        super.init(frame: .zero)

        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        imageView.image = image
    }

    private func layout() {
        addSubview(imageView)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        imageView.autoPinEdge(toSuperviewEdge: .top)
        imageView.autoPinEdge(toSuperviewEdge: .bottom)
    }
}
