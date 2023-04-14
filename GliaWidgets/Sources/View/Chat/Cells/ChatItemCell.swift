import UIKit
import PureLayout

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
        stackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            stackView.autoPinEdge(toSuperviewEdge: .bottom)
        }
    }
}
