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
        // iPhone 13, iOS 15.5
        TestDeviceConfig(
            systemVersion: "15.5",
            screenSize: CGSize(
                width: 390,
                height: 844
            ),
            screenScale: 3
        )
    ]

    static let possiblePrecision: Float = 1.0

    private static func checkSimulatorEnvironment() {
        guard SnapshotTestCase.testedDevices.contains(where: { $0.matchesCurrentDevice() }) else {
            fatalError("Attempting to run tests on a device for which we have not collected test data")
        }

        guard UIApplication.shared.preferredContentSizeCategory == .large else {
            fatalError("Tests must be run on a device that has Dynamic Type disabled")
        }
    }

    /// This method sets the name for the snapshot tests by taking one parameter. 
    /// Depending of the case passed in, either prefix, suffix, or nothing
    /// additional will be added to the the base name. The method returns a string.
    func nameForDevice(_ baseName: NameForDevice = .portrait) -> String {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let version = UIDevice.current.systemVersion
        let deviceName = "\(Int(size.width))x\(Int(size.height))-\(version)-\(Int(scale))x"

        switch baseName {
        case let .baseName(value):
            return [value, deviceName]
                .compactMap { $0 }
                .joined(separator: "-")
        case .portrait:
            return "\(deviceName)"
        case .landscape:
            return "\(deviceName)-landscape"
        }
    }

    /// All available cases for the snapshot tests name. This Enum
    /// conforms to ExpressibleByStringLiteral allowing a string to be
    /// passed instead of a case, that will convert it to baseName case.
    ///
    /// - baseName(String?) case is a string that can be added as prefix
    /// to the test name
    ///
    /// - portrait case serves as a default case for snapshot tests and
    /// won't add anything additional to the name
    ///
    /// - landscape case will add suffix to the end of the name
    enum NameForDevice: ExpressibleByStringLiteral {
        case baseName(String?)
        case portrait
        case landscape

        init(stringLiteral value: String) {
            self = .baseName(value)
        }
    }
}

extension SnapshotTestCase {
    /// Retrieves local configuration file for testing Unified Customization. Uses `json` file extension.
    ///
    /// - parameter fileName: Name of the file that should be retrieved
    ///
    /// - Returns: Parsed `RemoteConfiguration` object if file exists locally and `nil` if it does not.
    func retrieveRemoteConfigurationForUnifiedCustomization(_ fileName: String? = "MockConfiguration") -> RemoteConfiguration? {
        guard
            let url = Bundle(for: Self.self).url(forResource: fileName, withExtension: "json"),
            let jsonData = try? Data(contentsOf: url),
            let config = try? JSONDecoder().decode(RemoteConfiguration.self, from: .init(jsonData))
        else {
            return nil
        }
        return config
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

extension Snapshotting where Value == UIViewController, Format == UIImage {
    /// Strategy for making image references with largest dynamic font type for UIViewController.
    static var extra3LargeFontStrategy: Self {
        Self.image(
            traits: UITraitCollection(
                preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
            )
        )
    }
}

extension Snapshotting where Value == UIView, Format == UIImage {
    /// Strategy for making image references with largest dynamic font type for UIView.
    static var extra3LargeFontStrategy: Self {
        Self.image(
            traits: UITraitCollection(
                preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
            )
        )
    }

    static var extra3LargeFontStrategyLandscape: Self {
        let traits = UITraitCollection(traitsFrom: [
            .init(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        ] + commonTraitCollection)

        return Self.image(traits: traits)
    }

    static var imageLandscape: Self {
        let traits = UITraitCollection(traitsFrom: [
            .init(preferredContentSizeCategory: .medium),
        ] + commonTraitCollection)

        return Self.image(traits: traits)
    }

    private static var commonTraitCollection: [UITraitCollection] = [
        .init(layoutDirection: .leftToRight),
        .init(userInterfaceIdiom: .phone),
        .init(horizontalSizeClass: .regular),
        .init(verticalSizeClass: .compact),
    ]
}

extension Snapshotting where Value == UIViewController, Format == UIImage {
    static var extra3LargeFontStrategyLandscape: Self {
        let traits = UITraitCollection(traitsFrom: [
            .init(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        ] + commonTraitCollection)
        let safeArea: UIEdgeInsets = .init(top: 0, left: 47, bottom: 21, right: 47)
        let size: CGSize = .init(width: 844, height: 390)
        let viewImageConfig: ViewImageConfig = .init(safeArea: safeArea, size: size, traits: traits)

        return Self.image(on: viewImageConfig)
    }

    static var imageLandscape: Self {
        let traits = UITraitCollection(traitsFrom: [
            .init(preferredContentSizeCategory: .medium),
        ] + commonTraitCollection)
        let safeArea: UIEdgeInsets = .init(top: 0, left: 47, bottom: 21, right: 47)
        let size: CGSize = .init(width: 844, height: 390)
        let viewImageConfig: ViewImageConfig = .init(safeArea: safeArea, size: size, traits: traits)

        return Self.image(on: viewImageConfig)
    }

    private static var commonTraitCollection: [UITraitCollection] = [
        .init(layoutDirection: .leftToRight),
        .init(userInterfaceIdiom: .phone),
        .init(horizontalSizeClass: .regular),
        .init(verticalSizeClass: .compact),
    ]
}
