import Foundation
import UIKit

final class UnreadMessageDividerView: BaseView {
    static let accessibilityIdentifier = "chatTranscript_unreadMessageDivider_view"
    private let style: UnreadMessageDividerStyle
    private let textLabel = UILabel().makeView()
    private lazy var leadingLine = LineView(color: style.lineColor).makeView()
    private lazy var trailingLine = LineView(color: style.lineColor).makeView()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable)
    required init() {
        fatalError("init() has not been implemented")
    }

    init(style: UnreadMessageDividerStyle) {
        self.style = style
        super.init()
    }

    override func setup() {
        super.setup()
        addSubview(leadingLine)
        addSubview(textLabel)
        addSubview(trailingLine)

        textLabel.text = style.title
        textLabel.font = style.titleFont
        textLabel.textColor = style.titleColor
        textLabel.textAlignment = .center
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: textLabel
        )
        textLabel.isAccessibilityElement = false
        isAccessibilityElement = true
        accessibilityLabel = textLabel.text
        accessibilityIdentifier = Self.accessibilityIdentifier
    }

    override func defineLayout() {
        let lineHorizontalPadding = 18.0
        let labelSpacing = 8.0
        let lineVerticalPadding = 21.0

        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: lineVerticalPadding),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -lineVerticalPadding),

            leadingLine.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            leadingLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: lineHorizontalPadding),
            leadingLine.trailingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -labelSpacing),
            leadingLine.heightAnchor.constraint(equalToConstant: 1),

            trailingLine.centerYAnchor.constraint(equalTo: leadingLine.centerYAnchor),
            trailingLine.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: labelSpacing),
            trailingLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -lineHorizontalPadding),
            trailingLine.heightAnchor.constraint(equalTo: leadingLine.heightAnchor)
        ])
    }
}

extension UnreadMessageDividerView {
    final class LineView: BaseView {
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @available(*, unavailable)
        required init() {
            fatalError("init() has not been implemented")
        }

        required init(color: UIColor) {
            super.init()
            self.backgroundColor = color
        }
    }
}
