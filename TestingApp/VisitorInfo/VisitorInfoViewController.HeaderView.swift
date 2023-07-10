import UIKit

final class HeaderView: UITableViewHeaderFooterView {
    static var identifier: String { "\(Self.self)" }
    static var height: CGFloat { UITableView.automaticDimension }

    private lazy var titleLabel = UILabel()
    private lazy var customSegmentedControl = CustomSegmentedControl(frame: .zero).makeView()
    private lazy var actionButton = UIButton(type: .system)

    var props = Props(
        title: "",
        segments: [],
        selectedSegment: nil,
        actionButton: nil,
        segmentAccessibilityIdentifierPrefix: ""
    ) {
        didSet {
            guard props != oldValue else { return }
            renderProps()
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        let margins = 10.0

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)

        let stackView = UIStackView()
        stackView.spacing = margins
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(customSegmentedControl)
        customSegmentedControl.addTarget(
            self,
            action: #selector(handleSegmentedControlSelect),
            for: .valueChanged
        )

        stackView.addArrangedSubview(actionButton)
        actionButton.addTarget(
            self,
            action: #selector(handleActionButtonTap),
            for: .touchUpInside
        )
        actionButton.titleLabel?.textAlignment = .center
        actionButton.titleLabel?.font = .monospacedSystemFont(ofSize: 30, weight: .heavy)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margins),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margins),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margins),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margins),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margins),
            customSegmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func renderProps() {
        titleLabel.text = props.title
        renderedSegments = .init(segments: props.segments, selectedSegment: props.selectedSegment)
        actionButton.isHidden = props.actionButton == nil
        actionButton.accessibilityIdentifier = props.actionButton?.accIdentifier
        if let title = props.actionButton?.title {
            actionButton.setTitle(title, for: .normal)
        }
    }

    private var renderedSegments: RenderedSegments = .init(segments: [], selectedSegment: nil) {
        didSet {
            guard renderedSegments != oldValue else { return }
            var selectedIdx: Int?

            // Render list of segments if needed.
            if renderedSegments.segments != oldValue.segments {
                customSegmentedControl.segments = renderedSegments.segments.map(\.title)

                for (segment, idx) in zip(renderedSegments.segments, 0...) {
                    if renderedSegments.selectedSegment == segment {
                        selectedIdx = idx
                    }

                    customSegmentedControl.setAccessibilityIdentifier(
                        "\(props.segmentAccessibilityIdentifierPrefix)\(idx)",
                        at: idx
                    )
                }

            // Render segment selection if needed.
            } else if renderedSegments.selectedSegment != oldValue.selectedSegment {
                for (segment, idx) in zip(renderedSegments.segments, 0...) where renderedSegments.selectedSegment == segment {
                    selectedIdx = idx
                }
            }

            if let selectedIdx, customSegmentedControl.selectedSegmentIndex != selectedIdx {
                customSegmentedControl.setSelectedSegmentIndex(selectedIdx, sendActions: false)
            }

            customSegmentedControl.isHidden = renderedSegments.segments.isEmpty
        }
    }

    @objc
    private func handleActionButtonTap() {
        // Dismiss keyboard if something is being edited
        // when new attribute is added, to prevent
        // `tableView.begin/endUpdates` crash.
        if let tableView = self.superview(by: { $0 is UITableView }), tableView.isKeyboardPresented() {
            tableView.endEditing(true)
        } else {
            props.actionButton?.tap()
        }
    }

    @objc
    private func handleSegmentedControlSelect(_ control: CustomSegmentedControl) {
        props.segments[control.selectedSegmentIndex].select()
    }
}

extension HeaderView {
    struct Props: Equatable {
        struct Segment: Equatable {
            let title: String
            let select: Cmd
        }

        struct ActionButton: Equatable {
            let title: String
            let tap: Cmd
            let accIdentifier: String
        }

        let title: String
        let segments: [Segment]
        let selectedSegment: Segment?
        let actionButton: ActionButton?
        let segmentAccessibilityIdentifierPrefix: String
    }

    struct RenderedSegments: Equatable {
        let segments: [Props.Segment]
        let selectedSegment: Props.Segment?
    }
}

extension HeaderView.Props {
    init(headerTitle: String,
         segments: [HeaderView.Props.Segment] = [],
         selectedSegment: HeaderView.Props.Segment? = nil,
         actionButton: HeaderView.Props.ActionButton? = nil,
         segmentAccessibilityIdentifierPrefix: String = ""
    ) {
        self.title = headerTitle
        self.segments = segments
        self.selectedSegment = selectedSegment
        self.actionButton = actionButton
        self.segmentAccessibilityIdentifierPrefix = segmentAccessibilityIdentifierPrefix
    }
}
