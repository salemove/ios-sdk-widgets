import UIKit

/// Trailing-docked panel container used for the iPad side-panel presentation.
///
/// `panelContainer` hosts the chat/call navigation stack at a fixed width, while
/// `leadingContainer` is transparent and non-interactive until a call occupies it,
/// letting touches outside both containers fall through `EngagementPanelWindow`
/// to the integrator's app.
final class EngagementSplitViewController: UIViewController {
    static let panelWidth: CGFloat = 400

    private let panelContainer = UIView()
    private let leadingContainer = UIView()
    private var panelWidthConstraint: NSLayoutConstraint?

    private(set) var panelViewController: UIViewController?
    private(set) var leadingViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupContainers()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        panelWidthConstraint?.constant = Self.panelWidth(forSceneWidth: view.bounds.width)
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        panelWidthConstraint?.constant = Self.panelWidth(forSceneWidth: size.width)
    }

    /// Below the side-panel threshold (Split View, Stage Manager) the panel takes
    /// the whole window, which matches today's full-screen presentation and makes
    /// the window opaque to touches. Above it the panel keeps its fixed width.
    static func panelWidth(forSceneWidth sceneWidth: CGFloat) -> CGFloat {
        sceneWidth >= EngagementLayoutMode.sidePanelMinimumSceneWidth ? panelWidth : sceneWidth
    }

    func setPanel(_ viewController: UIViewController?) {
        replace(panelViewController, with: viewController, in: panelContainer)
        panelViewController = viewController
    }

    func setLeading(_ viewController: UIViewController?) {
        replace(leadingViewController, with: viewController, in: leadingContainer)
        leadingViewController = viewController
        // The leading region must stay transparent to touches while empty, so that
        // `EngagementPanelWindow.hitTest` can pass them through to the host app.
        leadingContainer.isUserInteractionEnabled = viewController != nil
    }
}

private extension EngagementSplitViewController {
    func setupContainers() {
        leadingContainer.backgroundColor = .clear
        // `setLeading` may run before the view loads (a direct call installs the
        // call screen before the panel window is shown), so the interaction flag
        // must reflect the current child rather than reset to `false`.
        leadingContainer.isUserInteractionEnabled = leadingViewController != nil
        panelContainer.backgroundColor = .clear

        [leadingContainer, panelContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        let panelWidthConstraint = panelContainer.widthAnchor.constraint(equalToConstant: Self.panelWidth)
        self.panelWidthConstraint = panelWidthConstraint

        NSLayoutConstraint.activate([
            panelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelContainer.topAnchor.constraint(equalTo: view.topAnchor),
            panelContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panelWidthConstraint,

            leadingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leadingContainer.trailingAnchor.constraint(equalTo: panelContainer.leadingAnchor),
            leadingContainer.topAnchor.constraint(equalTo: view.topAnchor),
            leadingContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func replace(_ current: UIViewController?, with new: UIViewController?, in container: UIView) {
        current?.willMove(toParent: nil)
        current?.view.removeFromSuperview()
        current?.removeFromParent()

        guard let new else { return }

        new.willMove(toParent: self)
        addChild(new)
        container.addSubview(new.view)
        new.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            new.view.topAnchor.constraint(equalTo: container.topAnchor),
            new.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            new.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            new.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        new.didMove(toParent: self)
    }
}
