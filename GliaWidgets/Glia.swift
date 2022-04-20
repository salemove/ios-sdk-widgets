import UIKit
import SalemoveSDK

/// Engagement media type.
public enum EngagementKind: Equatable {
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
public enum GliaEvent: Equatable {
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
public class Glia {
    /// A singleton to access the Glia's interface.
    public static let sharedInstance = Glia(environment: .live)

    /// Current engagement media type.
    public var engagement: EngagementKind { return rootCoordinator?.engagementKind ?? .none }

    /// Used to monitor engagement state changes.
    public var onEvent: ((GliaEvent) -> Void)?

    var rootCoordinator: RootCoordinator?
    var interactor: Interactor?
    private var environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

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

        let sdkConfiguration = try Salemove.Configuration(
            siteId: configuration.site,
            region: configuration.environment.region,
            authorizingMethod: configuration.authorizationMethod.coreAuthorizationMethod
        )
        interactor = Interactor(
            with: sdkConfiguration,
            queueID: queueId,
            visitorContext: visitorContext,
            environment: .init(
                coreSdk: environment.coreSdk,
                gcd: environment.gcd
            )
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

        let viewFactory = ViewFactory(
            with: theme,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding
            )
        )
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
    ///   - `SalemoveSDK.ConfigurationError.invalidRegionEndpoint`
    ///   - `SalemoveSDK.ConfigurationError.invalidSiteApiKey`
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
            features: features,
            environment: .init(
                chatStorage: environment.chatStorage,
                fetchFile: environment.coreSdk.fetchFile,
                sendSelectedOptionValue: environment.coreSdk.sendSelectedOptionValue,
                uploadFileToEngagement: environment.coreSdk.uploadFileToEngagement,
                audioSession: environment.audioSession,
                uuid: environment.uuid,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                gcd: environment.gcd,
                localFileThumbnailQueue: environment.localFileThumbnailQueue,
                uiImage: environment.uiImage,
                createFileDownload: environment.createFileDownload,
                fromHistory: environment.fromHistory,
                timerProviding: environment.timerProviding,
                fetchSiteConfigurations: environment.coreSdk.fetchSiteConfigurations,
                getCurrentEngagement: environment.coreSdk.getCurrentEngagement,
                submitSurveyAnswer: environment.coreSdk.submitSurveyAnswer
            )
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
        environment.coreSdk.clearSession()
        environment.chatStorage.dropDatabase()
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
        environment.coreSdk.fetchVisitorInfo(completion)
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
        environment.coreSdk.updateVisitorInfo(info, completion)
    }

    /// Ends active engagement if existing and closes Widgets SDK UI (includes bubble).
    public func endEngagement(_ completion: @escaping (Result<Void, Error>) -> Void) {

        defer {
            onEvent?(.ended)
            rootCoordinator = nil
        }

        guard interactor != nil else {
            completion(.failure(GliaError.sdkIsNotConfigured))
            return
        }

        interactor?.endSession(
            success: {
                completion(.success(()))
            }, failure: {
                completion(.failure($0))
            }
        )
    }
}
