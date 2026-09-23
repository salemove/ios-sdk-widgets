import GliaWidgets
import SwiftUI

@MainActor
class ContentViewPresenter: ObservableObject {
    private let gliaConfiguration: GliaConfiguration
    private var theme = Theme()
    private var gliaAuthentication: Glia.Authentication?
    private var queue: Queue?

    @Published var isSDKLoaded = false

    @Published var isVideoAvailable = false
    @Published var isAudioAvailable = false
    @Published var isChatAvailable = false
    @Published var isAsyncMessagesAvailable = false

    @Published var isAuthenticated = false

    init() {
        gliaConfiguration = GliaConfiguration()
        theme = customizeTheme()

        Task { [weak self] in
            await self?.initializeSDK()
        }
    }

    // Start the engagement of a desired `EngagementKind`.
    func startEngagement(_ kind: EngagementKind) {
        do {
            try Glia.sharedInstance.startEngagement(of: kind, in: [gliaConfiguration.queueId])
        } catch {
            print("Error starting engagement")
        }
    }

    // Authenticate user with token to start secure conversation
    // and display user data on operator side
    func authenticate() {
        Task { [weak self] in
            guard let self, let gliaAuthentication else { return }
            do {
                try await gliaAuthentication.authenticate(
                    with: gliaConfiguration.directIdToken,
                    accessToken: nil
                )
                isAuthenticated = true
            } catch {
                print("Error has happened: \(error.localizedDescription)")
            }
        }
    }

    func deauthenticate() {
        Task { [weak self] in
            guard let self, let gliaAuthentication else { return }
            do {
                try await gliaAuthentication.deauthenticate()
                isAuthenticated = false
            } catch {
                print("Error has happened: \(error.localizedDescription)")
            }
        }
    }

    // Show the visitor code to display code and start engagements with live observation
    func showVisitorCode() {
        var topViewController: UIViewController?
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else {
                continue
            }
            for window in windowScene.windows where window.isKeyWindow {
                topViewController = window.rootViewController
                break
            }
        }

        if let topViewController {
            Glia.sharedInstance.callVisualizer.showVisitorCodeViewController(from: topViewController)
        }
    }
}

private extension ContentViewPresenter {
    func initializeSDK() async {
        do {
            let configuration = Configuration(
                authorizationMethod: .siteApiKey(
                    id: gliaConfiguration.siteApiId,
                    secret: gliaConfiguration.siteApiSecret
                ),
                environment: gliaConfiguration.environment,
                site: gliaConfiguration.siteId
            )

            try await Glia.sharedInstance.configure(
                with: configuration,
                theme: theme
            )
            isSDKLoaded = true
            initializeAuthentication()
            await checkQueueEngagementsAvailability()
        } catch {
            print("Error has happened: \(error.localizedDescription)")
        }
    }

    func initializeAuthentication() {
        gliaAuthentication = try? Glia.sharedInstance.authentication(with: .allowedDuringEngagement)
    }

    // Customize and apply Theme
    func customizeTheme() -> Theme {
        let themeColors = ThemeColor(
            primary: .init(Colors.gliaPurple),
            baseLight: .white,
            baseDark: .init(Colors.gray),
            systemNegative: .systemPink
        )
        let colorStyle = ThemeColorStyle.custom(themeColors)

        theme = Theme(
            colorStyle: colorStyle,
            fontStyle: .default,
            showsPoweredBy: true
        )
        theme.chat.backgroundColor = .fill(color: .white)
        theme.minimizedBubble.badge?.backgroundColor = .fill(color: .systemPink)
        theme.minimizedBubble.badge?.fontColor = .white
        theme.minimizedBubble.badge?.font = .systemFont(ofSize: 14)

        return theme
    }

    func checkQueueEngagementsAvailability() async {
        do {
            let queues = try await Glia.sharedInstance.getQueues()
            let queue = queues.first(where: { $0.id == gliaConfiguration.queueId })
            self.queue = queue
            isVideoAvailable = queue?.isMediaTypeSupported(.video) ?? false
            isAudioAvailable = queue?.isMediaTypeSupported(.audio) ?? false
            isChatAvailable = queue?.isMediaTypeSupported(.text) ?? false
            isAsyncMessagesAvailable = queue?.isMediaTypeSupported(.messaging) ?? false
        } catch {
            print("Error has happened: \(error.localizedDescription)")
        }
    }

    // This is an example of how events are handled and could be observer in Glia Widgets
    func eventListener() {
        Glia.sharedInstance.onEvent = { event in
            switch event {
            case .started:
                break
            case .engagementChanged:
                break
            case .ended:
                break
            case .minimized:
                break
            case .maximized:
                break
            }
        }
    }
}

// Check if the desired queue is open and available for a certain media.
private extension GliaWidgets.Queue {
    func isMediaTypeSupported(_ mediaType: MediaType) -> Bool {
        status == .open && media.contains(mediaType)
    }
}
