import UIKit
import PureLayout

class ChatMessageCell: UITableViewCell {
    var view: UIView? {
        get { return contentView.subviews.first }
        set {
            contentView.subviews.first?.removeFromSuperview()

            if let view = newValue {
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
        view = nil
    }

    private func setup() {
        selectionStyle = .none
    }

    private func layout() {}
}
