import UIKit
import SalemoveSDK

/// Engagement media type.
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
    /// Engagement media type changed
    case engagementChanged(EngagementKind)
    /// Session has ended
    case ended
    /// Engagement window was minimized
    case minimized
    /// Engagement window was maximized
    case maximized
}

/// Used to provide `UIWindowScene` to the framework.
public protocol SceneProvider: AnyObject {
    @available(iOS 13.0, *)
    func windowScene() -> UIWindowScene?
}

/// Glia's engagement interface.
///
/// ## Integration
///     1. Add Glia iOS SDK to your app.
///     2. Add following privacy descriptions to your app's Info.plist:
///         Privacy - Microphone Usage Description
///         Privacy - Camera Usage Description
///         Privacy - Photo Library Additions Usage Description
///     3. Import `GliaWidgets` and `SalemoveSDK`:
///         import GliaWidgets
///         import SalemoveSDK
///     4. Create configuration:
///         let conf = Configuration(
///             appToken: "appToken",
///             environment: .europe,
///             site: "site"
///         )
///     5. Create visitor context:
///         let visitorContext = VisitorContext(
///             type: .page,
///             url: "https://www.yoursite.com"
///         )
///     6. Start the engagement:
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
///             break
///         case .engagementChanged(let kind):
///             break
///         case .ended:
///             break
///         case .minimized:
///             break
///         case .maximized:
///             break
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

    /// Current engagement media type.
    public var engagement: EngagementKind { return rootCoordinator?.engagementKind ?? .none }

    /// Used to monitor engagement state changes.
    public var onEvent: ((GliaEvent) -> Void)?

    private var rootCoordinator: RootCoordinator?

    private init() {}

    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
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

    /// Clear visitor session
    public func clearVisitorSession() {
        Salemove.sharedInstance.clearSession()

        guard
            let dbUrl = ChatStorage.dbUrl,
            FileManager.default.fileExists(atPath: dbUrl.standardizedFileURL.path)
        else { return }

        do {
            try FileManager.default.removeItem(at: dbUrl)
        } catch {
            print("DB has not been removed due to: '\(error)'.")
        }
    }
}
