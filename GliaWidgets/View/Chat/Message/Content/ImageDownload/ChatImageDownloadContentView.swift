import UIKit

class ChatImageDownloadContentView: UIView {
    enum State {
        case empty
        case image(url: URL)
    }

    private let imageView = UIImageView()
    private let style: ChatImageDownloadContentStyle
    private let state: ValueProvider<State>
    private let kInsets = UIEdgeInsets.zero
    private let kSize = CGSize(width: 240, height: 155)

    init(with style: ChatImageDownloadContentStyle,
         state: ValueProvider<State>) {
        self.style = style
        self.state = state
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

        update(for: state.value)
        state.addObserver(self) { state, _ in
            self.update(for: state)
        }
    }

    private func layout() {
        autoSetDimensions(to: kSize)

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
