import UIKit

final class MediaSelectorViewController: UIViewController {
    private let mediaSelectorView: MediaSelectorView
    let queueInformation: [QueueInformation]
    var delegate: ((DelegateEvent) -> Void)?

    init(queueInformation: [QueueInformation]) {
        self.queueInformation = queueInformation
        self.mediaSelectorView = MediaSelectorView(queueInformation: queueInformation)
        super.init(nibName: nil, bundle: nil)

        self.mediaSelectorView.delegate = { event in
            switch event {
            case .queueSelected(let queueInformation):
                self.delegate?(.queueSelected(queueInformation))
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = withContainer(mediaSelectorView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func withContainer(_ view: MediaSelectorView) -> UIView {
        let container = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(
                equalTo: container.safeAreaLayoutGuide.leadingAnchor,
                constant: 8
            ),
            view.trailingAnchor.constraint(
                equalTo: container.safeAreaLayoutGuide.trailingAnchor,
                constant: -8
            ),
            view.bottomAnchor.constraint(
                lessThanOrEqualTo: container.bottomAnchor,
                constant: -24
            )
        ])

        return container
    }
}

extension MediaSelectorViewController {
    enum DelegateEvent {
        case queueSelected(QueueInformation)
    }
}
