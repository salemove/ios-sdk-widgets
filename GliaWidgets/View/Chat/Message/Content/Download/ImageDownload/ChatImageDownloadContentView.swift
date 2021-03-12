import UIKit

class ChatImageDownloadContentView: ChatDownloadContentView {
    private let imageView = UIImageView()
    private let style: ChatImageDownloadContentStyle
    private let kInsets = UIEdgeInsets.zero
    private let kSize = CGSize(width: 240, height: 155)

    init(with style: ChatImageDownloadContentStyle,
         state: ValueProvider<State>) {
        self.style = style
        super.init(with: style, state: state)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        layer.cornerRadius = 4
        imageView.contentMode = .scaleAspectFill
    }

    override func layout() {
        super.layout()

        autoSetDimensions(to: kSize)

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: kInsets)
    }

    override func update(for state: State) {
        switch state {
        case .downloaded(_, _, url: let url):
            let image = UIImage(contentsOfFile: url.path)
            imageView.image = image
        default:
            imageView.image = nil
        }
    }
}
