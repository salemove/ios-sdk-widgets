#if DEBUG
import Foundation
import GliaCoreSDK

extension CoreSdkClient {
    static let mock = Self(
        pushNotifications: .mock,
        createAppDelegate: { .mock },
        clearSession: {},
        localeProvider: .mock,
        fetchVisitorInfo: { _ in },
        updateVisitorInfo: { _, _ in },
        configureWithConfiguration: { _, _ in },
        configureWithInteractor: { _ in },
        listQueues: { _ in },
        queueForEngagement: { _, _ in },
        requestMediaUpgradeWithOffer: { _, _ in },
        sendMessagePreview: { _, _ in },
        sendMessageWithMessagePayload: { _, _ in },
        cancelQueueTicket: { _, _ in },
        endEngagement: { _ in },
        requestEngagedOperator: { _ in },
        uploadFileToEngagement: { _, _, _ in },
        fetchFile: { _, _, _ in },
        getCurrentEngagement: { return nil },
        fetchSiteConfigurations: { _ in },
        submitSurveyAnswer: { _, _, _, _ in },
        authentication: { _ in .mock },
        fetchChatHistory: { _ in },
        requestVisitorCode: { _ in .mock },
        sendSecureMessagePayload: { _, _, _ in .mock },
        uploadSecureFile: { _, _, _ in .mock },
        getSecureUnreadMessageCount: { _ in },
        secureMarkMessagesAsRead: { _ in .mock },
        downloadSecureFile: { _, _, _ in .mock },
        startSocketObservation: {},
        stopSocketObservation: {},
        createSendMessagePayload: { _, _ in .mock() },
        createLogger: { _ in Logger.mock }
    )
}

extension CoreSdkClient.PushNotifications {
    static let mock = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken: { _, _ in },
        setPushHandler: { _ in },
        pushHandler: { nil }
    )
}

extension CoreSdkClient.AppDelegate {
    static let mock = Self(
        applicationDidFinishLaunchingWithOptions: { _, _ in false },
        applicationDidBecomeActive: { _ in }
    )
}

extension CoreSdkClient.LocaleProvider {
    static let mock = Self(getRemoteString: { _ in nil })
}

extension CoreSdkClient.EngagementFile {
    static func mock(id: String = "") -> CoreSdkClient.EngagementFile {
        .init(id: id)
    }

    static func mock(url: URL = .mock) -> CoreSdkClient.EngagementFile {
        .init(url: url)
    }

    static func mock(
        name: String = "",
        url: URL = .mock
    ) -> CoreSdkClient.EngagementFile {
        .init(
            name: name,
            url: url
        )
    }
}

extension CoreSdkClient.Salemove.Configuration {
    static func mock(
        siteId: String = "mocked-id",
        region: CoreSdkClient.Salemove.Region = .us,
        authMethod: CoreSdkClient.Salemove.AuthorizationMethod = .mock
    ) throws -> Self {
        try CoreSdkClient.Salemove.Configuration(
            siteId: siteId,
            region: region,
            authorizingMethod: authMethod
        )
    }
}

extension CoreSdkClient.Salemove.AuthorizationMethod {
    static let mock = Self.siteApiKey(id: "mockSiteApiKeyId", secret: "mockSiteApiKeySecret")

}

extension CoreSdkClient.VisitorContext {
    static let mock = CoreSdkClient.VisitorContext(.assetId(.init(rawValue: .mock)))

    static func mock(
        contextType: ContextType = .assetId(.init(rawValue: .mock))
    ) -> CoreSdkClient.VisitorContext {
        .init(contextType)
    }
}

extension CoreSdkClient.EngagementFileInformation {
    static func mock(
        id: String = "mockId",
        isSecurityScanningRequired: Bool = false,
        url: String? = "https://mock.mock/file.mock"
    ) throws -> CoreSdkClient.EngagementFileInformation {

        let jsonString = jsonFields(
            [
                url.map { jsonField("url", value: $0) },
                jsonField("fileId", value: id),
                jsonField("securityScanningRequired", value: isSecurityScanningRequired)
            ].compactMap { $0 }
        )

        return try mockFromJSONString(jsonString)
    }
}

extension CoreSdkClient.SingleChoiceOption {
    static func mock(text: String?, value: String?) throws -> CoreSdkClient.SingleChoiceOption {
        try mockFromJSONString(
            jsonFields(
                [
                    text.map { jsonField("text", value: $0) },
                    value.map { jsonField("value", value: $0) }
                ].compactMap { $0 }
            )
        )
    }
}

extension CoreSdkClient {
    class MockAudioStreamable: CoreSdkClient.AudioStreamable {
        var onHold: CoreSdkClient.StreamableOnHoldHandler?
        var muteFunc: () -> Void
        var unmuteFunc: () -> Void
        var getIsMutedFunc: () -> Bool
        var setIsMutedFunc: (Bool) -> Void
        var getIsRemoteFunc: () -> Bool
        var setIsRemoteFunc: (Bool) -> Void

        var isMuted: Bool {
            get { getIsMutedFunc() }
            set { setIsMutedFunc(newValue) }
        }
        var isRemote: Bool {
            get { getIsRemoteFunc() }
            set { setIsRemoteFunc(newValue) }
        }

        internal init(
            onHold: CoreSdkClient.StreamableOnHoldHandler?,
            muteFunc: @escaping () -> Void,
            unmuteFunc: @escaping () -> Void,
            getIsMutedFunc: @escaping () -> Bool,
            setIsMutedFunc: @escaping (Bool) -> Void,
            getIsRemoteFunc: @escaping () -> Bool,
            setIsRemoteFunc: @escaping (Bool) -> Void
        ) {
            self.onHold = onHold
            self.muteFunc = muteFunc
            self.unmuteFunc = unmuteFunc
            self.getIsMutedFunc = getIsMutedFunc
            self.setIsMutedFunc = setIsMutedFunc
            self.getIsRemoteFunc = getIsRemoteFunc
            self.setIsRemoteFunc = setIsRemoteFunc
        }

        func mute() {
            muteFunc()
        }

        func unmute() {
            unmuteFunc()
        }

        static func mock(
            onHold: CoreSdkClient.StreamableOnHoldHandler? = nil,
            muteFunc: @escaping () -> Void = {},
            unmuteFunc: @escaping () -> Void = {},
            getIsMutedFunc: @escaping () -> Bool = { false },
            setIsMutedFunc: @escaping (Bool) -> Void = { _ in },
            getIsRemoteFunc: @escaping () -> Bool = { false },
            setIsRemoteFunc: @escaping (Bool) -> Void = { _ in }
        ) -> MockAudioStreamable {
            .init(
                onHold: onHold,
                muteFunc: muteFunc,
                unmuteFunc: unmuteFunc,
                getIsMutedFunc: getIsMutedFunc,
                setIsMutedFunc: setIsMutedFunc,
                getIsRemoteFunc: getIsRemoteFunc,
                setIsRemoteFunc: setIsRemoteFunc
            )
        }
    }
}

extension CoreSdkClient {
    class MockVideoStreamable: CoreSdkClient.VideoStreamable {
        internal init(
            onHold: CoreSdkClient.StreamableOnHoldHandler?,
            getStreamViewFunc: @escaping () -> CoreSdkClient.StreamView,
            playVideoFunc: @escaping () -> Void,
            pauseFunc: @escaping () -> Void,
            resumeFunc: @escaping () -> Void,
            stopFunc: @escaping () -> Void,
            getIsPausedFunc: @escaping () -> Bool,
            setIsPausedFunc: @escaping (Bool) -> Void,
            getIsRemoteFunc: @escaping () -> Bool,
            setIsRemoteFunc: @escaping (Bool) -> Void
        ) {
            self.onHold = onHold
            self.getStreamViewFunc = getStreamViewFunc
            self.playVideoFunc = playVideoFunc
            self.pauseFunc = pauseFunc
            self.resumeFunc = resumeFunc
            self.stopFunc = stopFunc
            self.getIsPausedFunc = getIsPausedFunc
            self.setIsPausedFunc = setIsPausedFunc
            self.getIsRemoteFunc = getIsRemoteFunc
            self.setIsRemoteFunc = setIsRemoteFunc
        }

        func getStreamView() -> CoreSdkClient.StreamView {
            .init()
        }

        func playVideo() {
            playVideoFunc()
        }
        func pause() {
            pauseFunc()
        }
        func resume() {
            resumeFunc()
        }
        func stop() {
            stopFunc()
        }

        var isPaused: Bool {
            get {
                getIsPausedFunc()
            }

            set {
                setIsPausedFunc(newValue)
            }
        }

        var isRemote: Bool {
            get {
                getIsRemoteFunc()
            }

            set {
                setIsRemoteFunc(newValue)
            }
        }

        var onHold: CoreSdkClient.StreamableOnHoldHandler?
        var getStreamViewFunc: () -> CoreSdkClient.StreamView
        var playVideoFunc: () -> Void
        var pauseFunc: () -> Void
        var resumeFunc: () -> Void
        var stopFunc: () -> Void
        var getIsPausedFunc: () -> Bool
        var setIsPausedFunc: (Bool) -> Void
        var getIsRemoteFunc: () -> Bool
        var setIsRemoteFunc: (Bool) -> Void

        static func mock(
            onHold: CoreSdkClient.StreamableOnHoldHandler? = nil,
            getStreamViewFunc: @escaping () -> CoreSdkClient.StreamView = { .init() },
            playVideoFunc: @escaping () -> Void = {},
            pauseFunc: @escaping () -> Void = {},
            resumeFunc: @escaping () -> Void = {},
            stopFunc: @escaping () -> Void = {},
            getIsPausedFunc: @escaping () -> Bool = { false },
            setIsPausedFunc: @escaping (Bool) -> Void = { _ in },
            getIsRemoteFunc: @escaping () -> Bool = { false },
            setIsRemoteFunc: @escaping (Bool) -> Void = { _ in }
        ) -> MockVideoStreamable {
            .init(
                onHold: onHold,
                getStreamViewFunc: getStreamViewFunc,
                playVideoFunc: playVideoFunc,
                pauseFunc: pauseFunc,
                resumeFunc: resumeFunc,
                stopFunc: stopFunc,
                getIsPausedFunc: getIsPausedFunc,
                setIsPausedFunc: setIsPausedFunc,
                getIsRemoteFunc: getIsRemoteFunc,
                setIsRemoteFunc: setIsRemoteFunc
            )
        }
    }
}

extension CoreSdkClient.Operator {
    static func mock(
        id: String = "mockId",
        name: String = "Mock Operator",
        picture: CoreSdkClient.OperatorPicture? = nil,
        availableMedia: [CoreSdkClient.MediaType]? = [.text, .audio, .video]
    ) -> CoreSdkClient.Operator {
        CoreSdkClient.Operator(
            id: id,
            name: name,
            picture: picture,
            availableMedia: availableMedia
        )
    }
}

extension CoreSdkClient.QueueTicket {
    static let mock = CoreSdkClient.QueueTicket(
        id: "mock-queue-ticket-id"
    )
}

extension CoreSdkClient.SalemoveError {
    static func mock(
        reason: String = "mock",
        error: Error? = nil
    ) -> CoreSdkClient.SalemoveError {
        CoreSdkClient.SalemoveError(
            reason: reason,
            error: error
        )
    }
}

extension CoreSdkClient.Authentication {
    static let mock = Self()
}

extension CoreSdkClient.Message {
    static func mock(
        id: String = "id",
        content: String = "content",
        sender: MessageSender = .mock,
        attachment: Attachment? = nil,
        metadata: Metadata? = nil
    ) -> Message {
        .init(
            id: id,
            content: content,
            sender: sender,
            attachment: attachment,
            metadata: metadata
        )
    }
}

extension MessageSender {
    static let mock = Self.init(type: .visitor)
}

extension CoreSdkClient.Cancellable {
    static let mock = CoreSdkClient.Cancellable()
}

extension CoreSdkClient {
    static var reactiveSwiftDateSchedulerMock: CoreSdkClient.ReactiveSwift.DateScheduler {
        CoreSdkClient.ReactiveSwift.TestScheduler()
    }
}

extension CoreSdkClient.Site.AllowedFileSenders {
    struct Mock: Codable {
        let `operator`: Bool
        let visitor: Bool
    }
}

extension CoreSdkClient.Site.AllowedFileSenders.Mock {
    static let mock = CoreSdkClient.Site.AllowedFileSenders.Mock.init(
        operator: false,
        visitor: false
    )

    static func mock(
        operator: Bool = false,
        visitor: Bool = false
    ) -> CoreSdkClient.Site.AllowedFileSenders.Mock {
        CoreSdkClient.Site.AllowedFileSenders.Mock(
            operator: `operator`,
            visitor: visitor
        )
    }

}

extension CoreSdkClient.Site.AllowedFileSenders {
    static func mock(
        operator: Bool = false,
        visitor: Bool = false
    ) throws -> CoreSdkClient.Site.AllowedFileSenders {
        try JSONDecoder().decode(
            CoreSdkClient.Site.AllowedFileSenders.self,
            from: JSONEncoder()
                .encode(
                    CoreSdkClient.Site.AllowedFileSenders.Mock(
                        operator: `operator`,
                        visitor: visitor
                    )
                )
        )
    }
}

extension CoreSdkClient.Site {
    static func mock(
        id: UUID = .mock,
        allowedFileSenders: AllowedFileSenders.Mock = .mock,
        maskingRegularExpressions: [String] = [],
        visitorAppDefaultLocale: String = "en-US",
        mobileObservationEnabled: Bool = true,
        mobileConfirmDialogEnabled: Bool = true,
        mobileObservationIndicationEnabled: Bool = true
    ) throws -> Self {
        struct Mock: Codable {
            let id: UUID
            let allowedFileSenders: CoreSdkClient.Site.AllowedFileSenders.Mock
            let maskingRegularExpressions: [String]
            let visitorAppDefaultLocale: String
            let mobileObservationEnabled: Bool
            let mobileConfirmDialogEnabled: Bool
            let mobileObservationIndicationEnabled: Bool
        }
        return try JSONDecoder()
            .decode(
                CoreSdkClient.Site.self,
                from: JSONEncoder()
                    .encode(
                        Mock(
                            id: id,
                            allowedFileSenders: allowedFileSenders,
                            maskingRegularExpressions: maskingRegularExpressions,
                            visitorAppDefaultLocale: visitorAppDefaultLocale,
                            mobileObservationEnabled: mobileObservationEnabled,
                            mobileConfirmDialogEnabled: mobileConfirmDialogEnabled,
                            mobileObservationIndicationEnabled: mobileObservationIndicationEnabled
                        )
                    )
            )
    }
}

extension CoreSdkClient.Queue {
    static func mock(
        id: String = "",
        name: String = "",
        status: QueueStatus = .unknown,
        isDefault: Bool = false,
        media: [MediaType] = []
    ) -> CoreSdkClient.Queue {
        CoreSdkClient.Queue(
            id: id,
            name: name,
            status: status,
            isDefault: isDefault,
            media: media
        )
    }
}

extension CoreSdkClient.Engagement {
    static func mock(
        id: String = "",
        engagedOperator: Operator? = nil,
        source: EngagementSource = .coreEngagement,
        fetchSurvey: @escaping FetchSurvey = { _, _ in },
        restartedFromEngagementId: String? = nil,
        media: Engagement.Media = .init(audio: nil, video: nil)
    ) -> CoreSdkClient.Engagement {
        .init(
            id: id,
            engagedOperator: engagedOperator,
            source: source,
            fetchSurvey: fetchSurvey,
            restartedFromEngagementId: restartedFromEngagementId,
            mediaStreams: media
        )
    }
}
#endif
