import UIKit

private extension CGFloat {
    static let placeholderVerticalInset: CGFloat = 4
    static let placeholderHorizontalInset: CGFloat = 8
}

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

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = bounds.width - 2 * .placeholderHorizontalInset
        let size = placeholderLabel.sizeThatFits(
            CGSize(
                width: width,
                height: .greatestFiniteMagnitude
            )
        )
        placeholderLabel.frame = .init(
            x: .placeholderVerticalInset,
            y: .placeholderHorizontalInset,
            width: width,
            height: size.height - 2 * .placeholderVerticalInset
        )
    }

    private func setupPlaceholder() {
        addSubview(placeholderLabel)
        renderStyle()
    }

    private func renderStyle() {
        placeholderLabel.font = style.placeholder.font
        placeholderLabel.textColor = UIColor(hex: style.placeholder.color)
        placeholderLabel.textAlignment = style.placeholder.alignment

        font = style.text.font
        textColor = UIColor(hex: style.text.color)
        textAlignment = style.text.alignment
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
