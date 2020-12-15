import UIKit
import PureLayout

class ChatItemCell: UITableViewCell {
    enum Content {
        case none
        case sentMessage(SentChatMessageView)
        case receivedMessage(ReceivedChatMessageView)

        var view: UIView? {
            switch self {
            case .none:
                return nil
            case .sentMessage(let view):
                return view
            case .receivedMessage(let view):
                return view
            }
        }
    }

    var content: Content = .none {
        didSet {
            switch content {
            case .none:
                contentView.subviews.first?.removeFromSuperview()
            default:
                guard let view = content.view else { return }
                contentView.subviews.first?.removeFromSuperview()
                contentView.addSubview(view)
                view.autoPinEdgesToSuperviewEdges()
            }
        }
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
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
        selectionStyle = .none
        contentView.backgroundColor = .lightGray
    }

    private func layout() {}
}
