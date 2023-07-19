import UIKit

final class QuickReplyButtonCell: UICollectionViewCell {
    static let identifier = "QuickReplyButtonCell"

    var props: Props = .nop {
        didSet {
            button.setTitle(props.title, for: .normal)
            button.accessibilityLabel = props.title
        }
    }

    var style: GvaQuickReplyButtonStyle? {
        didSet {
            guard let style else { return }
            applyStyle(style)
        }
    }

    private lazy var button: AdjustedTouchAreaButton = {
        let button = AdjustedTouchAreaButton(touchAreaInsets: (dx: 0, dy: -8))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = .init(top: 6, left: 16, bottom: 6, right: 16)
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func tap() {
        props.action()
    }
}

// MARK: - Private

private extension QuickReplyButtonCell {
    func applyStyle(_ style: GvaQuickReplyButtonStyle) {
        switch style.backgroundColor {
        case .fill(let color):
            button.backgroundColor = color
        case .gradient(let colors):
            button.makeGradientBackground(colors: colors)
        }
        button.setTitleColor(style.textColor, for: .normal)
        button.titleLabel?.font = style.textFont
        button.layer.cornerRadius = style.cornerRadius
        button.layer.borderColor = style.borderColor.cgColor
        button.layer.borderWidth = style.borderWidth
    }
}

// MARK: - Props

extension QuickReplyButtonCell {
    struct Props {
        let title: String
        let action: Cmd

        static var nop: Props { .init(title: "", action: .nop) }
    }
}
