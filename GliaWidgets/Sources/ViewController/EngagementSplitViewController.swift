import UIKit

/// Trailing-docked panel container used for the iPad side-panel presentation.
///
/// `panelContainer` hosts the chat navigation stack at a fixed width, while
/// `leadingContainer` is transparent and non-interactive until a call occupies it,
/// letting touches outside both containers fall through `EngagementPanelWindow`
/// to the integrator's app. While a call is active the panel is collapsed so the
/// call takes the whole scene; the call's chat button reveals it again.
final class EngagementSplitViewController: UIViewController {
    static let panelWidth: CGFloat = 400
    private static let collapseAnimationDuration: TimeInterval = 0.3

    private let panelContainer = UIView()
    private let leadingContainer = UIView()
    private var panelWidthConstraint: NSLayoutConstraint?
    /// Tracks whether this container is on screen, because appearance callbacks
    /// are forwarded to children manually (see `shouldAutomaticallyForwardAppearanceMethods`).
    private var hasAppeared = false

    private(set) var panelViewController: UIViewController?
    private(set) var leadingViewController: UIViewController?
    private(set) var isPanelCollapsed = false

    // Children are told about appearance by hand so that a collapsed panel reads
    // as "disappeared" even though the window stays visible. UIKit's automatic
    // forwarding would otherwise mark the hidden chat as active, and unread
    // messages received behind the call would never be counted.
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupContainers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visibleChildren.forEach { $0.beginAppearanceTransition(true, animated: animated) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visibleChildren.forEach { $0.endAppearanceTransition() }
        hasAppeared = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visibleChildren.forEach { $0.beginAppearanceTransition(false, animated: animated) }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visibleChildren.forEach { $0.endAppearanceTransition() }
        hasAppeared = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        panelWidthConstraint?.constant = currentPanelWidth(forSceneWidth: view.bounds.width)
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        panelWidthConstraint?.constant = currentPanelWidth(forSceneWidth: size.width)
    }

    /// Below the side-panel threshold (Split View, Stage Manager) the panel takes
    /// the whole window, which matches today's full-screen presentation and makes
    /// the window opaque to touches. Above it the panel keeps its fixed width.
    static func panelWidth(forSceneWidth sceneWidth: CGFloat) -> CGFloat {
        sceneWidth >= EngagementLayoutMode.sidePanelMinimumSceneWidth ? panelWidth : sceneWidth
    }

    func setPanel(_ viewController: UIViewController?) {
        replace(panelViewController, with: viewController, in: panelContainer, isVisible: !isPanelCollapsed)
        panelViewController = viewController
    }

    func setLeading(_ viewController: UIViewController?) {
        replace(leadingViewController, with: viewController, in: leadingContainer, isVisible: true)
        leadingViewController = viewController
        // The leading region must stay transparent to touches while empty, so that
        // `EngagementPanelWindow.hitTest` can pass them through to the host app.
        leadingContainer.isUserInteractionEnabled = viewController != nil
    }

    /// Collapses the panel to zero width so the leading content fills the scene,
    /// or reveals it again at its regular width.
    func setPanelCollapsed(_ collapsed: Bool, animated: Bool) {
        guard collapsed != isPanelCollapsed else { return }
        isPanelCollapsed = collapsed
        loadViewIfNeeded()

        if hasAppeared {
            panelViewController?.beginAppearanceTransition(!collapsed, animated: animated)
        }
        if !collapsed {
            panelContainer.isHidden = false
        }
        panelWidthConstraint?.constant = currentPanelWidth(forSceneWidth: view.bounds.width)

        let finish = { [weak self] in
            guard let self else { return }
            self.panelContainer.isHidden = self.isPanelCollapsed
            if self.hasAppeared {
                self.panelViewController?.endAppearanceTransition()
            }
        }

        if animated, view.window != nil {
            UIView.animate(
                withDuration: Self.collapseAnimationDuration,
                animations: { self.view.layoutIfNeeded() },
                completion: { _ in finish() }
            )
        } else {
            view.layoutIfNeeded()
            finish()
        }
    }
}

private extension EngagementSplitViewController {
    var visibleChildren: [UIViewController] {
        [leadingViewController, isPanelCollapsed ? nil : panelViewController].compactMap { $0 }
    }

    func currentPanelWidth(forSceneWidth sceneWidth: CGFloat) -> CGFloat {
        isPanelCollapsed ? 0 : Self.panelWidth(forSceneWidth: sceneWidth)
    }

    func setupContainers() {
        leadingContainer.backgroundColor = .clear
        // `setLeading` may run before the view loads (a direct call installs the
        // call screen before the panel window is shown), so the interaction flag
        // must reflect the current child rather than reset to `false`.
        leadingContainer.isUserInteractionEnabled = leadingViewController != nil
        panelContainer.backgroundColor = .clear
        panelContainer.isHidden = isPanelCollapsed

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

    func replace(
        _ current: UIViewController?,
        with new: UIViewController?,
        in container: UIView,
        isVisible: Bool
    ) {
        if let current {
            let notifiesAppearance = hasAppeared && isVisible
            current.willMove(toParent: nil)
            if notifiesAppearance {
                current.beginAppearanceTransition(false, animated: false)
            }
            current.view.removeFromSuperview()
            current.removeFromParent()
            if notifiesAppearance {
                current.endAppearanceTransition()
            }
        }

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

        if hasAppeared, isVisible {
            new.beginAppearanceTransition(true, animated: false)
            new.endAppearanceTransition()
        }
    }
}
