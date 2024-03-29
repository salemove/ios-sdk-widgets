import UIKit

class ChatItemCell: UITableViewCell {
    enum Content {
        case none
        case queueOperator(ConnectView)
        case outgoingMessage(VisitorChatMessageView)
        case visitorMessage(VisitorChatMessageView)
        case operatorMessage(OperatorChatMessageView)
        case choiceCard(ChoiceCardView)
        case customCard(CustomCardContainerView)
        case callUpgrade(ChatCallUpgradeView)
        case unreadMessagesDivider(UnreadMessageDividerView)
        case systemMessage(SystemMessageView)
        case gvaResponseText(GvaResponseTextView)
        case gvaPersistentButton(GvaPersistentButtonView)
        case gvaQuickReply(GvaResponseTextView)
        case gvaGallery(GvaGalleryListView, CGFloat)

        var view: UIView? {
            switch self {
            case .none:
                return nil
            case .queueOperator(let view):
                return view
            case .outgoingMessage(let view):
                return view
            case .visitorMessage(let view):
                return view
            case .operatorMessage(let view):
                return view
            case .choiceCard(let view):
                return view
            case .customCard(let view):
                return view
            case .callUpgrade(let view):
                return view
            case let .unreadMessagesDivider(view):
                return view
            case let .systemMessage(view):
                return view
            case let .gvaResponseText(view):
                return view
            case let .gvaPersistentButton(view):
                return view
            case let .gvaQuickReply(view):
                return view
            case let .gvaGallery(view, _):
                return view
            }
        }
    }

    var content: Content = .none {
        didSet {
            switch content {
            case .none:
                stackView.removeArrangedSubviews()
            default:
                guard let view = content.view else { return }
                stackView.replaceArrangedSubviews(with: [view])
            }
        }
    }

    private let stackView = UIStackView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        defineLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        content = .none
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        isAccessibilityElement = false
        stackView.isAccessibilityElement = false
        contentView.isAccessibilityElement = false
    }

    private func defineLayout() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += stackView.layoutInSuperview(edges: .horizontal)
        constraints += stackView.layoutInSuperview(edges: .top)
        constraints += stackView.layoutInSuperview(edges: .bottom, priority: .defaultHigh)
    }
}
