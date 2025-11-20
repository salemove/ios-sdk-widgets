//
//  ScreenChangeTracker.swift
//  GliaWidgets
//
//  Created by Yevhen Kyivskyi on 27/10/2025.
//

import Foundation


public class ScreenChangeTracker {

    /// Shared singleton instance for easy access from anywhere in the app.
    public static let shared = ScreenChangeTracker()

    /// The time interval (in seconds) between polls.
    /// A shorter interval is more responsive but uses more resources.
    public var pollingInterval: TimeInterval = 1 // Default: 500ms

    /// A callback closure that is triggered when a new screen or scroll position is detected.
    /// Parameters:
    /// - screenName: The class name of the visible view controller
    /// - scrollOffset: The Y-axis scroll offset (nil if no scroll view exists)
    /// - previousScreenTimeSpent: Time spent on the PREVIOUS screen in seconds (nil if no previous screen)
    public var onScreenDidChange: ((String, CGFloat?, Int?) -> Void)?

    private var pollTimer: Timer?
    private var lastSeenSignature: String?
    private var screenEntryTime: Date?

    // A private initializer to enforce the singleton pattern.
    private init() {}

    /// Starts the polling mechanism.
    ///
    /// Call this when your SDK or application initializes.
    /// For example, in `SceneDelegate.scene(_:willConnectTo:options:)`
    /// or `AppDelegate.application(_:didFinishLaunchingWithOptions:)`.
    public func start() {
        // Ensure we don't start multiple timers
        stop()

        // Start a new timer that fires repeatedly
        pollTimer = Timer.scheduledTimer(
            timeInterval: pollingInterval,
            target: self,
            selector: #selector(checkForScreenChange),
            userInfo: nil,
            repeats: true
        )
    }

    /// Stops the polling mechanism.
    public func stop() {
        pollTimer?.invalidate()
        pollTimer = nil
        lastSeenSignature = nil
        screenEntryTime = nil
    }

    /// Returns the time spent on the current screen in seconds (rounded).
    /// Returns nil if no screen has been tracked yet.
    private func getTimeSpentOnCurrentScreen() -> Int? {
        guard let entryTime = screenEntryTime else { return nil }
        let elapsed = Date().timeIntervalSince(entryTime)
        return Int(round(elapsed))
    }

    /// The core function that is fired by the timer.
    /// This function finds the visible screen and checks if it's new or if scroll position changed.
    @objc private func checkForScreenChange() {
        guard let visibleVC = getVisibleViewController() else {
            // No visible VC found. This is rare but possible during transitions.
            return
        }

        // Get the screen name using combined heuristic approach
        let screenName = getScreenName(for: visibleVC)

        // Enable scroll view tracking
        let scrollView = findPrimaryScrollView(in: visibleVC)
        let scrollSignature = buildScrollSignature(for: scrollView)

        // Build full state signature
        let fullSignature = screenName + scrollSignature

        // 1. Detect the Change
        if fullSignature != lastSeenSignature {
            // Enable scroll view tracking
            let scrollOffset = scrollView?.contentOffset.y
            let roundedOffset = scrollOffset.map { round($0 / 150.0) * 150.0 }

            // 2. Check if this is a new screen (not just a scroll change)
            let previousScreenName = lastSeenSignature?.components(separatedBy: "|").first
            let isNewScreen = previousScreenName != screenName

            // 3. Calculate time spent on PREVIOUS screen BEFORE resetting timer
            var previousScreenTimeSpent: Int?
            if isNewScreen {
                // Get the time spent on the previous screen before we reset the timer
                previousScreenTimeSpent = getTimeSpentOnCurrentScreen()

                // Now reset timer to start tracking the NEW screen
                screenEntryTime = Date()
            }
            // If same screen but different scroll offset, keep the existing timer running

            // 4. Update the state
            lastSeenSignature = fullSignature

            // 5. Trigger the Action (pass previous screen time if this is a new screen)
            onScreenDidChange?(screenName, roundedOffset, previousScreenTimeSpent)
        }
    }

    // MARK: - View Hierarchy Traversal

    /// Finds the currently visible view controller by traversing the hierarchy.
    public func getVisibleViewController() -> UIViewController? {
        // 1. Get the Key Window
        guard let window = getKeyWindow() else { return nil }

        // 2. Filter out system alerts and special windows
        // Only process normal-level windows (not alerts, statusBar, etc.)
        guard window.windowLevel == .normal else {
            return nil
        }

        // 3. Get the Root
        guard let rootViewController = window.rootViewController else { return nil }

        // 4. Traverse the Stack
        return findTopViewController(from: rootViewController)
    }

    /// Helper function to find the application's key window,
    /// supporting modern scene-based apps and older architectures.
    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            // iOS 15+ provides a direct `keyWindow` property on the scene
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.keyWindow
        } else if #available(iOS 13.0, *) {
            // iOS 13-14 requires finding the window that `isKeyWindow`
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first { $0.isKeyWindow }
        } else {
            // Fallback for iOS 12 and below
            return UIApplication.shared.keyWindow
        }
    }

    /// Recursively traverses the view controller stack to find the top-most one.
    private func findTopViewController(from controller: UIViewController) -> UIViewController {

        // 1. Check for Modals
        // If a view controller is presented modally, it's on top.
        if let presented = controller.presentedViewController {
            return findTopViewController(from: presented)
        }

        // 2. Check for Navigation Controller
        // If it's a navigation controller, check its visible child.
        if let navigationController = controller as? UINavigationController {
            if let visible = navigationController.visibleViewController {
                // Recurse on the visible child
                return findTopViewController(from: visible)
            } else {
                // No visible child, so the nav controller itself is on top
                return navigationController
            }
        }

        // 3. Check for Tab Bar Controller
        // If it's a tab bar, check its selected tab's view controller.
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                // Recurse on the selected child
                return findTopViewController(from: selected)
            } else {
                // No selected tab, so the tab controller itself is on top
                return tabController
            }
        }

        // 4. Base Case
        // If it's not a modal, navigation, or tab controller,
        // then this is the top-most view controller.
        return controller
    }

    // MARK: - Scroll View Detection

    /// Finds the primary scroll view in a view controller.
    /// Uses recursive traversal with smart filtering to support both UIKit and SwiftUI.
    /// Strategy:
    /// 1. Recursively find all scroll views in the hierarchy
    /// 2. Filter out system/internal scroll views (UITextView, UITableView, UICollectionView, small views)
    /// 3. Filter out horizontal-only scroll views (only track vertical scrolling)
    /// 4. Return the tallest remaining scroll view
    private func findPrimaryScrollView(in viewController: UIViewController) -> UIScrollView? {
        var allScrollViews: [UIScrollView] = []
        findAllScrollViews(in: viewController.view, found: &allScrollViews)

        let filtered = allScrollViews.filter { scrollView in
            if scrollView is UITextView {
                return false
            }

            if scrollView.frame.height < 100 {
                return false
            }

            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.height
            let hasVerticalScroll = contentHeight > frameHeight || scrollView.alwaysBounceVertical

            if !hasVerticalScroll {
                return false
            }

            return true
        }

        return filtered.max(by: { $0.frame.height < $1.frame.height })
    }

    private func findAllScrollViews(in view: UIView, found: inout [UIScrollView]) {
        if let scrollView = view as? UIScrollView {
            found.append(scrollView)
        }

        for subview in view.subviews {
            findAllScrollViews(in: subview, found: &found)
        }
    }

    /// Builds the scroll signature portion of the state string.
    /// Returns empty string if no scroll view, otherwise "|scroll:{roundedOffset}"
    private func buildScrollSignature(for scrollView: UIScrollView?) -> String {
        guard let scrollView = scrollView else { return "" }

        let offsetY = scrollView.contentOffset.y
        let roundedOffset = round(offsetY / 50.0) * 50.0

        return "|scroll:\(roundedOffset)"
    }

    // MARK: - Screen Name Detection

    /// Gets the screen name using a combined heuristic approach.
    /// Priority order:
    /// 1. Accessibility identifier (developer-provided)
    /// 2. Navigation title (if available)
    /// 3. Mirror introspection for SwiftUI (if UIHostingController)
    /// 4. View controller class name (fallback)
    private func getScreenName(for viewController: UIViewController) -> String {
        // 1. Check for accessibility identifier (most reliable)
        if let accessibilityId = viewController.view.accessibilityIdentifier,
           !accessibilityId.isEmpty {
            return accessibilityId
        }

        // 2. Check for navigation title (common in SwiftUI)
        let navItem = viewController.navigationItem

        if let title = navItem.title, !title.isEmpty {
            return title
        }

        // 3. Try Mirror introspection for SwiftUI (if it's a hosting controller)
        let className = String(describing: type(of: viewController))
        if className.contains("HostingController") {
            if let swiftUIName = extractSwiftUIViewName(from: viewController) {
                return cleanupTypeName(swiftUIName)
            }
        }

        // 4. Fallback to class name
        return className
    }

    /// Attempts to extract the SwiftUI view name from a UIHostingController using Mirror.
    /// Returns nil if extraction fails.
    private func extractSwiftUIViewName(from hostingController: UIViewController) -> String? {
        let mirror = Mirror(reflecting: hostingController)

        // Look for "rootView" property in UIHostingController
        for child in mirror.children {
            if child.label == "rootView" {
                let typeName = String(describing: type(of: child.value))
                return typeName
            }
        }
        return nil
    }

    /// Cleans up type names by removing module prefixes and mangling.
    /// Example: "MyApp.CardView" -> "CardView"
    private func cleanupTypeName(_ typeName: String) -> String {
        var cleaned = typeName

        // Remove module prefix: "MyApp.CardView" -> "CardView"
        if let lastDot = cleaned.lastIndex(of: ".") {
            cleaned = String(cleaned[cleaned.index(after: lastDot)...])
        }

        // Remove generic type parameters: "CardView<String>" -> "CardView"
        if let firstAngleBracket = cleaned.firstIndex(of: "<") {
            cleaned = String(cleaned[..<firstAngleBracket])
        }

        return cleaned
    }
}
