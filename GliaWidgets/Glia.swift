import UIKit
import SalemoveSDK

/// Kind of an engagement.
public enum EngagementKind {
    /// No engagement
    case none
    /// Chat
    case chat
    /// Audio call
    case audioCall
    /// Video call
    case videoCall
}

/// An event providing engagement state information.
public enum GliaEvent {
    /// Session was started
    case started
    /// Engagement kind changed
    case engagementChanged(EngagementKind)
    /// Session has ended
    case ended
    /// Engagement window was minimized
    case minimized
    /// Engagement window was maximized
    case maximized
}

/// Used to provide `UIWindowScene` to the framework.
public protocol SceneProvider: class {
    @available(iOS 13.0, *)
    func windowScene() -> UIWindowScene?
}

/// Glia's engagement interface.
///
/// ## Integration
///     1. Add Glia iOS SDK to you app
///     2. Import `GliaWidgets` and `SalemoveSDK`:
///         import GliaWidgets
///         import SalemoveSDK
///     3. Create configuration:
///         let conf = Configuration(
///             appToken: "appToken",
///             apiToken: "apiToken",
///             environment: .europe,
///             site: "site"
///         )
///     4. Create visitor context:
///         let visitorContext = VisitorContext(
///             type: .page,
///             url: "https://www.yoursite.com"
///         )
///     5. Start the engagement:
///         do {
///             try Glia.sharedInstance.start(
///                 .chat,
///                 configuration: conf,
///                 queueID: "queueID",
///                 visitorContext: visitorContext
///             )
///         } catch {
///             // configuration error
///         }
///
/// To listen Glia's events, use `onEvent`:
///
///     Glia.sharedInstance.onEvent = { event in
///         switch event {
///         case .started:
///             print("STARTED")
///         case .engagementChanged(let kind):
///             print("CHANGED:", kind)
///         case .ended:
///             print("ENDED")
///         case .minimized:
///             print("MINIMIZED")
///         case .maximized:
///             print("MAXIMIZED")
///         }
///     }
///
/// To use custom colors and fonts, create a new theme with `ThemeColor` and `ThemeFont`:
///
///     let color = ThemeColor(
///         primary: primaryColorCell.color,
///         ...
///     )
///     let font = ThemeFont(
///         header1: header1FontCell.selectedFont,
///         ...
///     )
///
///     let colorStyle: ThemeColorStyle = .custom(color)
///     let fontStyle: ThemeFontStyle = .custom(font)
///
///     let theme = Theme(
///         colorStyle: colorStyle,
///         fontStyle: fontStyle
///     )
///
/// and pass it to the `start(...)` method.
///
/// To customize a theme, you can override its properties. For example:
///
///     let theme = Theme()
///     theme.chat.backButton = HeaderButtonStyle(image: UIImage(), color: .red)
///     theme.chat.messageEntry.messageColor = .blue
///
public class Glia {
    /// A singleton to access the Glia's interface.
    public static let sharedInstance = Glia()

    /// Current engagement kind.
    public var engagement: EngagementKind { return rootCoordinator?.engagementKind ?? .none }

    /// Used to monitor engagement state changes.
    public var onEvent: ((GliaEvent) -> Void)?

    private var rootCoordinator: RootCoordinator?

    private init() {}

    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Kind of the engagement.
    ///   - configuration: Engagement configuration.
    ///   - queueID: Queue identifier.
    ///   - visitorContext: Visitor context.
    ///   - theme: A custom theme to use with the engagement.
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to the first active foreground scene.
    ///
    /// - throws:
    ///   - `ConfigurationError.invalidSite`
    ///   - `ConfigurationError.invalidEnvironment`
    ///   - `ConfigurationError.invalidAppToken`
    ///   - `ConfigurationError.invalidApiToken`
    ///
    public func start(
        _ engagementKind: EngagementKind,
        configuration: Configuration,
        queueID: String,
        visitorContext: VisitorContext,
        theme: Theme = Theme(),
        sceneProvider: SceneProvider? = nil
    ) throws {
        guard engagement == .none else {
            print("Warning: trying to start new Glia session while session is already active.")
            return
        }
        let interactor = try Interactor(
            with: configuration,
            queueID: queueID,
            visitorContext: visitorContext
        )
        let viewFactory = ViewFactory(with: theme)
        startRootCoordinator(
            with: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind
        )
    }

    private func startRootCoordinator(
        with interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind
    ) {
        rootCoordinator = RootCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind
        )
        rootCoordinator?.delegate = { [weak self] event in
            switch event {
            case .started:
                self?.onEvent?(.started)
            case .engagementChanged(let engagementKind):
                self?.onEvent?(.engagementChanged(engagementKind))
            case .ended:
                self?.rootCoordinator = nil
                self?.onEvent?(.ended)
            case .minimized:
                self?.onEvent?(.minimized)
            case .maximized:
                self?.onEvent?(.maximized)
            }
        }
        rootCoordinator?.start()
    }
}
