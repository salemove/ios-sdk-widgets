import UIKit

class BadgeView: UIView {
    var newItemCount: Int = 0 {
        didSet {
            if newItemCount <= 0 {
                isHidden = true
            } else {
                isHidden = false
                countLabel.text = "\(newItemCount)"
            }
        }
    }
    let size: CGFloat = 18

    private let style: BadgeStyle
    private let countLabel = UILabel()

    public init(with style: BadgeStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        clipsToBounds = true
        layer.cornerRadius = size / 2
        backgroundColor = style.backgroundColor

        countLabel.font = style.font
        countLabel.textColor = style.fontColor
        countLabel.textAlignment = .center
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.8
    }

    private func layout() {
        autoSetDimensions(to: CGSize(width: size, height: size))

        addSubview(countLabel)
        countLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
    }
}
