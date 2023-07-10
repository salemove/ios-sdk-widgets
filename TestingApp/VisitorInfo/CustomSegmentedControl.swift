import UIKit

protocol CustomSegmentedControlDelegate: AnyObject {
    func segmentedControl(_ segmentedControl: CustomSegmentedControl, didSelectSegmentAt index: Int)
}

class CustomSegmentedControl: UIControl {
    weak var delegate: CustomSegmentedControlDelegate?

    private var buttons = [UIButton]()
    private (set) var selectedSegmentIndex = 0

    var segments: [String] = [] {
        didSet {
            setupSegments()
        }
    }

    var textColor: UIColor = .gray {
        didSet {
            updateButtonAppearance()
        }
    }

    var selectedTextColor: UIColor = .label {
        didSet {
            updateButtonAppearance()
        }
    }

    var segmentSpacing: CGFloat = 8 {
        didSet {
            stackView.spacing = segmentSpacing
            invalidateIntrinsicContentSize()
        }
    }

    var cornerRadius: CGFloat = 8 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    var borderColor: UIColor = .gray {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = segmentSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
        return stackView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // MARK: - View setup

    private func setupView() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        backgroundColor = .clear

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        setupSegments()
    }

    private func setupSegments() {
        // Remove previous buttons
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll(keepingCapacity: true)

        // Create and add buttons for each segment
        for title in segments {
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }

        // Update UI appearance
        updateButtonAppearance()
    }

    private func updateButtonAppearance() {
        for (index, button) in zip(0..., buttons) {
            button.tintColor = .clear
            button.setTitleColor(
                index == selectedSegmentIndex ? selectedTextColor : textColor,
                for: .normal
            )
            let fontSize = UIFont.systemFontSize - 2

            button.titleLabel?.font = index == selectedSegmentIndex ? .boldSystemFont(ofSize: fontSize) :
                .systemFont(ofSize: fontSize)
        }
    }

    // MARK: - Segment Handling

    @objc private func segmentTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }
        setSelectedSegment(index, sendActions: true)
    }

    private func setSelectedSegment(_ index: Int, sendActions: Bool) {
        if selectedSegmentIndex != index {
            selectedSegmentIndex = index
            updateButtonAppearance()
            if sendActions {
                self.sendActions(for: .valueChanged)
                delegate?.segmentedControl(self, didSelectSegmentAt: index)
            }
        }
    }

    // MARK: - Public API

    func setSelectedSegmentIndex(_ index: Int, sendActions: Bool) {
        guard segments.indices.contains(index) else { return }
        setSelectedSegment(index, sendActions: sendActions)
    }

    func setTitle(_ title: String, forSegmentAt index: Int) {
        guard segments.indices.contains(index) else { return }
        segments[index] = title
        buttons[index].setTitle(title, for: .normal)
        invalidateIntrinsicContentSize()
    }

    func titleForSegment(at index: Int) -> String? {
        guard segments.indices.contains(index) else { return nil }
        return segments[index]
    }

    func setAccessibilityIdentifier(_ identifier: String, at index: Int) {
        guard segments.indices.contains(index) else { return }
        stackView.arrangedSubviews[index].accessibilityIdentifier = identifier
    }
}
