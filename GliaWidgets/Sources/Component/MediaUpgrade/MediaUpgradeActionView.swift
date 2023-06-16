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
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        constraints += imageView.match(.width, value: 60)
        constraints += imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        constraints += imageView.layoutInSuperview(edges: .vertical)
        constraints += imageView.layoutInSuperview(edges: .leading)

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints += titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor)
        constraints += titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        constraints += titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)

        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints += infoLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor)
        constraints += infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        constraints += infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        constraints += infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    }

    @objc private func tapped() {
        tap?()
    }
}
