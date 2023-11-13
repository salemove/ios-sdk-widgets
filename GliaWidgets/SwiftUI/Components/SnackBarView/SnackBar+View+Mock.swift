import SwiftUI
import Combine

extension SnackBar.ContentView {
    static func mock() -> UIViewController {
        let publisher = CurrentValueSubject<ViewState, Never>(.disappear)
        let snackbar: SnackBar.ContentView = .init(
            style: .defaultStyle,
            publisher: publisher.eraseToAnyPublisher(),
            isAnimated: false
        )
        let view = UIHostingController(rootView: snackbar)
        let vc = UIViewController()

        let hostingController: UIHostingController<SnackBar.ContentView>
        hostingController = UIHostingController(rootView: snackbar)
        hostingController.willMove(toParent: vc)
        vc.addChild(hostingController)
        vc.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: vc)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: vc.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        publisher.send(.appear("This is mock snackbar"))
        return view
    }
}
