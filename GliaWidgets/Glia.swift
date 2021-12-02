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
///             // ConfigurationError or GliaError
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
    private var interactor: Interactor?

    private init() {}

    /// Setup SDK using specific engagement configuration without starting the engagement.
    /// - Parameters:
    ///   - configuration: Engagement configuration.
    ///   - queueId: Queue identifier.
    ///   - visitorContext: Visitor context.
    public func configure(
        with configuration: Configuration,
        queueId: String,
        visitorContext: VisitorContext
    ) throws {
        interactor = try Interactor(
            with: configuration,
            queueID: queueId,
            visitorContext: visitorContext
        )
    }

    /// Starts the engagement.
    ///
    /// - Parameters:
    ///   - engagementKind: Engagement media type.
    ///   - theme: A custom theme to use with the engagement.
    ///   - visitorContext: Visitor context.
    ///   - features: Set of features to be enabled in the SDK.
    ///   - sceneProvider: Used to provide `UIWindowScene` to the framework. Defaults to the first active foreground scene.
    ///
    /// - throws:
    ///   - `SalemoveSDK.ConfigurationError.invalidSite`
    ///   - `SalemoveSDK.ConfigurationError.invalidEnvironment`
    ///   - `SalemoveSDK.ConfigurationError.invalidAppToken`
    ///   - `GliaError.engagementExists
    ///   - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that `configure(with:queueID:visitorContext:)` must be called initially prior to this method,
    /// because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func startEngagement(
        engagementKind: EngagementKind,
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        guard engagement == .none else {
            throw GliaError.engagementExists
        }

        guard let interactor = self.interactor else {
            throw GliaError.sdkIsNotConfigured
        }

        let viewFactory = ViewFactory(with: theme)
        startRootCoordinator(
            with: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind,
            features: features
        )
    }

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
    ///   - `SalemoveSDK.ConfigurationError.invalidSite`
    ///   - `SalemoveSDK.ConfigurationError.invalidEnvironment`
    ///   - `SalemoveSDK.ConfigurationError.invalidAppToken`
    ///   - `GliaError.engagementExists`
    ///
    public func start(
        _ engagementKind: EngagementKind,
        configuration: Configuration,
        queueID: String,
        visitorContext: VisitorContext,
        theme: Theme = Theme(),
        features: Features = .all,
        sceneProvider: SceneProvider? = nil
    ) throws {
        try configure(
            with: configuration,
            queueId: queueID,
            visitorContext: visitorContext
        )

        try startEngagement(
            engagementKind: engagementKind,
            theme: theme,
            features: features,
            sceneProvider: sceneProvider
        )
    }

    public func resume() throws {
        guard engagement != .none else {
            throw GliaError.engagementNotExist
        }
        rootCoordinator?.maximize()
    }

    private func startRootCoordinator(
        with interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementKind: EngagementKind,
        features: Features
    ) {
        rootCoordinator = RootCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            sceneProvider: sceneProvider,
            engagementKind: engagementKind,
            features: features
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

    /// Fetch current Visitor's information.
    ///
    /// The information provided by this endpoint is available to all the Operators observing or interacting with the
    /// Visitor. This means that this endpoint can be used to provide additional context about the Visitor to the
    /// Operators.
    ///
    /// - Parameters:
    ///   - completion: A callback that will return the update result or `SalemoveError`
    ///
    /// If the request is unsuccessful for any reason then the completion will have an Error.
    /// The Error may have one of the following causes:
    ///
    /// - `SalemoveSDK.GeneralError.internalError`
    /// - `SalemoveSDK.GeneralError.networkError`
    /// - `SalemoveSDK.ConfigurationError.invalidSite`
    /// - `SalemoveSDK.ConfigurationError.invalidEnvironment`
    /// - `SalemoveSDK.ConfigurationError.invalidAppToken`
    /// - `SalemoveSDK.ConfigurationError.invalidApiToken`
    /// - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that in case of engagement has not been started yet, `configure(with:queueID:visitorContext:)` must be called initially prior to this method,
    /// because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func fetchVisitorInfo(completion: @escaping (Result<Salemove.VisitorInfo, Error>) -> Void) {
        guard interactor != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        Salemove.sharedInstance.fetchVisitorInfo(completion)
    }

    /// Update current Visitor's information.
    ///
    /// The information provided by this endpoint is available to all the Operators observing or interacting with the
    /// Visitor. This means that this endpoint can be used to provide additional context about the Visitor to the
    /// Operators.
    ///
    /// In a similar manner custom attributes can be also be used to provide additional context. For example, if your
    /// site separates paying users from free users, then setting a custom attribute of 'user_type' with a value of
    /// either 'free' or 'paying' depending on the Visitor's account can help Operators prioritize different Visitors.
    ///
    /// - Parameters:
    ///   - info: The information for updating Visitor
    ///   - completion: A callback that will return the update result or `SalemoveError`
    ///
    /// If the request is unsuccessful for any reason then the completion will have an Error.
    /// The Error may have one of the following causes:
    ///
    /// - `SalemoveSDK.GeneralError.internalError`
    /// - `SalemoveSDK.GeneralError.networkError`
    /// - `SalemoveSDK.ConfigurationError.invalidSite`
    /// - `SalemoveSDK.ConfigurationError.invalidEnvironment`
    /// - `SalemoveSDK.ConfigurationError.invalidAppToken`
    /// - `SalemoveSDK.ConfigurationError.invalidApiToken`
    /// - `GliaError.sdkIsNotConfigured`
    ///
    /// - Important: Note, that in case of engagement has not been started yet, `configure(with:queueID:visitorContext:)` must be called initially prior to this method,
    /// because `GliaError.sdkIsNotConfigured` will occur otherwise.
    ///
    public func updateVisitorInfo(
        _ info: VisitorInfoUpdate,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard interactor != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }
        Salemove.sharedInstance.updateVisitorInfo(info, completion: completion)
    }
}
