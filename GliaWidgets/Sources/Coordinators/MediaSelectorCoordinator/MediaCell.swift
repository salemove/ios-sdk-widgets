import UIKit

final class MediaCell: BaseView {
    lazy var titleLabel = UILabel().make { label in
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .natural
        label.isUserInteractionEnabled = false
    }

    lazy var subtitleLabel = UILabel().make { label in
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .natural
        label.isUserInteractionEnabled = false
    }

    lazy var imageView = UIImageView().make { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.gliaLogo.image
        imageView.tintColor = UIColor.systemGray3
        imageView.isUserInteractionEnabled = false
    }

    lazy var stackView = UIStackView.make(.horizontal, spacing: 16)(
        imageView,
        labelStackView
    )

    lazy var labelStackView = UIStackView.make(.vertical, spacing: 8)(
        titleLabel,
        subtitleLabel
    )

    private let contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    var onClicked: (() -> Void)?
    private var tapGesture: UITapGestureRecognizer!

    init(title: String, subtitle: String) {
        super.init()
        titleLabel.text = title
        subtitleLabel.text = subtitle
        setup()
    }

    override func setup() {
        super.setup()

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
    }

    @objc private func didTap() {
        onClicked?()
    }

    override func defineLayout() {
        super.defineLayout()

        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        constraints += stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left)
        constraints += stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)
        constraints += stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
        constraints += stackView.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top)

        constraints += imageView.widthAnchor.constraint(equalToConstant: 48)
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor
        layer.cornerRadius = 8
    }

    required init() {
        fatalError("init() has not been implemented")
    }
}
