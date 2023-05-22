import GliaWidgets
import GliaCoreSDK
import SwiftUI

class ContentViewPresenter: ObservableObject {
    private let gliaConfiguration: GliaConfiguration
    private var theme = Theme()
    private var queue: Queue?

    @Published var isVideoAvailable = false
    @Published var isAudioAvailable = false
    @Published var isChatAvailable = false

    init() {
        gliaConfiguration = GliaConfiguration()
        theme = customizeTheme()

        // To use any methods from iOS Core SDK (e.g. `GliaCore.listQueues`),
        //  you need to initialize `CoreSDK` separately with your site's credentials.
        initializeCoreSDK {
            GliaCore.sharedInstance.listQueues { [weak self] queues, error in
                guard error == nil else {
                    print("Error has happened: \(error!.reason)")
                    return
                }
                let queue = queues?.first(where: { $0.id == self?.gliaConfiguration.queueId })
                self?.queue = queue
                self?.isVideoAvailable = queue?.isMediaTypeSupported(.video) ?? false
                self?.isAudioAvailable = queue?.isMediaTypeSupported(.audio) ?? false
                self?.isChatAvailable = queue?.isMediaTypeSupported(.text) ?? false
            }
        }
    }

    // Configure listening of Glia's events
    private func eventListener() {
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

    // Start the engagement of a desired `EngagementKind`.
    func startEngagement(_ kind: EngagementKind) {
        do {
            try Glia.sharedInstance.start(
                kind,
                configuration: gliaConfiguration.composeConfiguration(),
                queueID: gliaConfiguration.queueId,
                visitorContext: nil,
                theme: theme
            )
        } catch {
            print("Error starting engagement")
        }
    }

    // Configure Glia, for Core SDK.
    private func initializeCoreSDK(completion: @escaping () -> Void) {
        do {
            let configuration = try GliaCore.Configuration(
                siteId: gliaConfiguration.siteId,
                region: gliaConfiguration.environment.gliaCoreRegion,
                authorizingMethod: .siteApiKey(id: gliaConfiguration.siteApiId, secret: gliaConfiguration.siteApiSecret)
            )

            GliaCore.sharedInstance.configure(
                with: configuration,
                completion: completion
            )
        } catch {
            print("Error has happened: \(error.localizedDescription)")
        }
    }

    // Customize and apply Theme
    private func customizeTheme() -> Theme {
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
        theme.chat.backgroundColor = .white
        theme.minimizedBubble.badge?.backgroundColor = .systemPink
        theme.minimizedBubble.badge?.fontColor = .white
        theme.minimizedBubble.badge?.font = .systemFont(ofSize: 14)

        return theme
    }
}

// Check if the desired queue is open and available for a certain media.
private extension GliaCoreSDK.Queue {
    func isMediaTypeSupported(_ mediaType: MediaType) -> Bool {
        state.status == .open && state.media.contains(mediaType)
    }
}
