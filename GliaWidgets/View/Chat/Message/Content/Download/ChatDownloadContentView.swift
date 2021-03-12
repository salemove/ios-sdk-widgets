import UIKit

class ChatDownloadContentView: UIView {
    enum State {
        case none
        case downloading(name: String?, size: Double?, progress: ValueProvider<Double>)
        case downloaded(name: String?, size: Double?, url: URL)
        case error(Error)
    }

    enum Error {
        case network
        case generic
    }

    let state: ValueProvider<State>

    private let style: ChatDownloadContentStyle

    init(with style: ChatDownloadContentStyle,
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

    func update(for state: State) {}

    func setup() {
        backgroundColor = style.backgroundColor

        update(for: state.value)
        state.addObserver(self) { state, _ in
            self.update(for: state)
        }
    }

    func layout() {}
}
