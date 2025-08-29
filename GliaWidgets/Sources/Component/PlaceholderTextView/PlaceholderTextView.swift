import UIKit

final class PlaceholderTextView: UITextView {
    private var style: Style {
        didSet {
            renderStyle()
        }
    }

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: label
        )
        return label
    }()

    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    override var text: String! {
        didSet {
            placeholderLabel.isHidden = !(text?.isEmpty ?? true)
        }
    }

    init(style: Style) {
        self.style = style
        super.init(frame: .zero, textContainer: nil)

        setupPlaceholder()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func applyStyle(_ style: Style) {
        self.style = style
        renderStyle()
    }

    private func setupPlaceholder() {
        addSubview(placeholderLabel)

        // Add constraints to position the label
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])

        renderStyle()
    }

    private func renderStyle() {
        placeholderLabel.font = style.placeholder.font
        placeholderLabel.textColor = UIColor(hex: style.placeholder.color)
        font = style.text.font
        textColor = UIColor(hex: style.text.color)
    }
}

extension PlaceholderTextView {
    struct Style {
        let text: Theme.Text
        let placeholder: Theme.Text
        let accessibility: Accessibility
    }
}

extension PlaceholderTextView.Style {
    struct Accessibility {
        var isFontScalingEnabled: Bool
    }
}
