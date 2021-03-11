import UIKit

class ChatMessageImageFileContentView: UIView {
    enum State {
        case empty
        case image(url: URL)
    }

    var state: State = .empty {
        didSet { update(for: state) }
    }

    private let imageView = UIImageView()
    private let style: ChatMessageImageFileContentStyle
    private let kInsets = UIEdgeInsets.zero

    init(with style: ChatMessageImageFileContentStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = style.backgroundColor
        layer.cornerRadius = 4

        imageView.contentMode = .scaleAspectFill
    }

    private func layout() {
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: kInsets)
    }

    private func update(for state: State) {
        switch state {
        case .empty:
            imageView.image = nil
        case .image(url: let url):
            let image = UIImage(contentsOfFile: url.path)
            imageView.image = image
        }
    }
}
