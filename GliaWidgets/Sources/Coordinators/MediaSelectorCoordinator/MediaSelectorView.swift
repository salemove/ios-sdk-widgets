import UIKit

final class MediaSelectorView: BaseView {
    lazy var stackView = UIStackView.make(.vertical, spacing: 24) (
        titleLabel
    )

    lazy var titleLabel = UILabel().make { label in
        label.text = "How would you like to talk?"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
    }

    lazy var chatCell = MediaCell(title: "Chat", subtitle: "For the texter in all of us!")
    lazy var audioCell = MediaCell(title: "Audio", subtitle: "Speak through your computer!")
    lazy var videoCell = MediaCell(title: "Video", subtitle: "You'll see us, but we won't see you")
    lazy var messagingCell = MediaCell(title: "Messaging", subtitle: "Asynchronous communication")

    let queueInformation: [QueueInformation]
    var delegate: ((DelegateEvent) -> Void)?
    private let contentInsets = UIEdgeInsets(top: 24, left: 24, bottom: 21, right: 24)

    init(queueInformation: [QueueInformation]) {
        self.queueInformation = queueInformation
        super.init()
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func setup() {
        super.setup()

        clipsToBounds = true
        layer.masksToBounds = false

        chatCell.onClicked = { [weak self] in
            if let queueInformation = self?.queueInformation.first(where: { $0.kind == .chat }) {
                self?.handleTap(withQueueInformation: queueInformation)
            }
        }

        audioCell.onClicked = { [weak self] in
            if let queueInformation = self?.queueInformation.first(where: { $0.kind == .audioCall }) {
                self?.handleTap(withQueueInformation: queueInformation)
            }
        }

        videoCell.onClicked = { [weak self] in
            if let queueInformation = self?.queueInformation.first(where: { $0.kind == .videoCall }) {
                self?.handleTap(withQueueInformation: queueInformation)
            }
        }

        messagingCell.onClicked = { [weak self] in
            let filter: (QueueInformation) -> Bool = {
                $0.kind == .messaging(.welcome) ||
                $0.kind == .messaging(.chatTranscript)
            }

            if let queueInformation = self?.queueInformation.first(where: filter) {
                self?.handleTap(withQueueInformation: queueInformation)
            }
        }
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

        if queueInformation.contains(where: { $0.kind == .chat }) {
            stackView.addArrangedSubview(chatCell)
        }

        if queueInformation.contains(where: { $0.kind == .audioCall }) {
            stackView.addArrangedSubview(audioCell)
        }

        if queueInformation.contains(where: { $0.kind == .videoCall }) {
            stackView.addArrangedSubview(videoCell)
        }

        if queueInformation.contains(where: { $0.kind == .messaging(.welcome) || $0.kind == .messaging(.chatTranscript) }) {
            stackView.addArrangedSubview(messagingCell)
        }
    }

    override func layoutSubviews() {
        backgroundColor = .white

        layer.cornerRadius = 30

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(
                width: 30,
                height: 30
            )
        ).cgPath

        renderShadow()
    }

    func renderShadow() {
        layer.shadowColor = UIColor.black.withAlphaComponent(0.16).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        layer.shadowRadius = 24.0
        layer.shadowOpacity = 1.0
    }

    func handleTap(withQueueInformation queueInformation: QueueInformation) {
        delegate?(.queueSelected(queueInformation))
    }
}

extension MediaSelectorView {
    enum DelegateEvent {
        case queueSelected(QueueInformation)
    }
}
