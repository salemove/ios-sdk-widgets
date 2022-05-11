@testable import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class SnapshotTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        SnapshotTestCase.checkSimulatorEnvironment()
    }
}

extension SnapshotTestCase {
    private struct TestDeviceConfig {
        let systemVersion: String
        let screenSize: CGSize
        let screenScale: CGFloat

        func matchesCurrentDevice() -> Bool {
            let device = UIDevice.current
            let screen = UIScreen.main

            return device.systemVersion == systemVersion
                && screen.bounds.size == screenSize
                && screen.scale == screenScale
        }
    }

    private static let testedDevices = [
        // iPhone 13, iOS 15.2
        TestDeviceConfig(
            systemVersion: "15.2",
            screenSize: CGSize(
                width: 390,
                height: 844
            ),
            screenScale: 3
        )
    ]

    static let possiblePrecision: Float = 0.99

    private static func checkSimulatorEnvironment() {
        guard SnapshotTestCase.testedDevices.contains(where: { $0.matchesCurrentDevice() }) else {
            fatalError("Attempting to run tests on a device for which we have not collected test data")
        }

        guard UIApplication.shared.preferredContentSizeCategory == .large else {
            fatalError("Tests must be run on a device that has Dynamic Type disabled")
        }
    }

    func nameForDevice(baseName: String? = nil) -> String {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let version = UIDevice.current.systemVersion
        let deviceName = "\(Int(size.width))x\(Int(size.height))-\(version)-\(Int(scale))x"

        return [baseName, deviceName]
            .compactMap { $0 }
            .joined(separator: "-")
    }
}

extension Snapshotting where Value == UIView, Format == UIImage {
    /// Snapshots the current view with colored overlays of each accessibility element it contains, as well as an
    /// approximation of the description that VoiceOver will read for each element.
    ///
    /// - parameter showActivationPoints: When to show indicators for elements' accessibility activation points.
    /// Defaults to showing activation points only when they are different than the default activation point for that
    /// element.
    /// - parameter useMonochromeSnapshot: Whether or not the snapshot of the `view` should be monochrome. Using a
    /// monochrome snapshot makes it more clear where the highlighted elements are, but may make it difficult to
    /// read certain views. Defaults to `true`.
    /// - parameter drawHierarchyInKeyWindow: Whether or not to draw the view hierachy in the key window, rather than
    /// rendering the view's layer. This enables the rendering of `UIAppearance` and `UIVisualEffect`s.
    /// - parameter markerColors: The array of colors which will be chosen from when creating the overlays
    /// - parameter precision: The percentage of pixels that must match.
    public static func accessibilityImage(
        showActivationPoints activationPointDisplayMode: ActivationPointDisplayMode = .whenOverridden,
        useMonochromeSnapshot: Bool = true,
        drawHierarchyInKeyWindow: Bool = false,
        markerColors: [UIColor] = [],
        precision: Float = 1
    ) -> Snapshotting {
        guard isRunningInHostApplication else {
            fatalError("Accessibility snapshot tests cannot be run in a test target without a host application")
        }

        return Snapshotting<UIView, UIImage>
            .image(
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                precision: precision
            )
            .pullback { view in
                let containerView = AccessibilitySnapshotView(
                    containedView: view,
                    viewRenderingMode: drawHierarchyInKeyWindow ? .drawHierarchyInRect : .renderLayerInContext,
                    markerColors: markerColors,
                    activationPointDisplayMode: activationPointDisplayMode
                )

                let window = UIWindow(frame: UIScreen.main.bounds)
                window.makeKeyAndVisible()
                containerView.center = window.center
                window.addSubview(containerView)

                do {
                    try containerView.parseAccessibility(useMonochromeSnapshot: useMonochromeSnapshot)
                } catch AccessibilitySnapshotView.Error.containedViewExceedsMaximumSize {
                    fatalError(
                        """
                        View is too large to render monochrome snapshot. Try setting useMonochromeSnapshot to false or \
                        use a different iOS version. In particular, this is known to fail on iOS 13, but was fixed in \
                        iOS 14.
                        """
                    )
                } catch AccessibilitySnapshotView.Error.containedViewHasUnsupportedTransform {
                    fatalError(
                        """
                        View has an unsupported transform for the specified snapshot parameters. Try using an identity \
                        transform or changing the view rendering mode to render the layer in the graphics context.
                        """
                    )
                } catch {
                    fatalError("Failed to render snapshot image")
                }

                containerView.sizeToFit()

                return containerView
            }
    }
}

extension Snapshotting where Value == UIViewController, Format == UIImage {
    /// Snapshots the current view with colored overlays of each accessibility element it contains, as well as an
    /// approximation of the description that VoiceOver will read for each element.
    ///
    /// - parameter showActivationPoints: When to show indicators for elements' accessibility activation points.
    /// Defaults to showing activation points only when they are different than the default activation point for that
    /// element.
    /// - parameter useMonochromeSnapshot: Whether or not the snapshot of the `view` should be monochrome. Using a
    /// monochrome snapshot makes it more clear where the highlighted elements are, but may make it difficult to
    /// read certain views. Defaults to `true`.
    /// - parameter drawHierarchyInKeyWindow: Whether or not to draw the view hierachy in the key window, rather than
    /// rendering the view's layer. This enables the rendering of `UIAppearance` and `UIVisualEffect`s.
    /// - parameter markerColors: The array of colors which will be chosen from when creating the overlays
    /// - parameter precision: The percentage of pixels that must match.
    public static func accessibilityImage(
        showActivationPoints activationPointDisplayMode: ActivationPointDisplayMode = .whenOverridden,
        useMonochromeSnapshot: Bool = true,
        drawHierarchyInKeyWindow: Bool = false,
        markerColors: [UIColor] = [],
        precision: Float = 1
    ) -> Snapshotting {
        return Snapshotting<UIView, UIImage>
            .accessibilityImage(
                showActivationPoints: activationPointDisplayMode,
                useMonochromeSnapshot: useMonochromeSnapshot,
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                markerColors: markerColors,
                precision: precision
            )
            .pullback { viewController in
                viewController.view
            }
    }
}
