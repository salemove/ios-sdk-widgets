import UIKit

class MediaUpgradeActionView: UIView {
    var tap: (() -> Void)?

    private let style: MediaUpgradeActionStyle
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()

    init(with style: MediaUpgradeActionStyle) {
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
        backgroundColor = style.backgroundColor
        layer.borderColor = style.borderColor.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 3.0

        imageView.image = style.icon
        imageView.tintColor = style.iconColor
        imageView.contentMode = .center

        titleLabel.text = style.title
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        titleLabel.numberOfLines = 0

        infoLabel.text = style.info
        infoLabel.font = style.infoFont
        infoLabel.textColor = style.infoColor
        infoLabel.numberOfLines = 0

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)
    }

    private func layout() {
        imageView.autoSetDimension(.width, toSize: 60)
        imageView.autoSetDimension(.height, toSize: 60, relation: .greaterThanOrEqual)

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)

        addSubview(titleLabel)
        titleLabel.autoPinEdge(.left, to: .right, of: imageView)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 12)

        addSubview(infoLabel)
        infoLabel.autoPinEdge(.left, to: .right, of: imageView)
        infoLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 4)
        infoLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 12)
        infoLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
    }

    @objc private func tapped() {
        tap?()
    }
}
