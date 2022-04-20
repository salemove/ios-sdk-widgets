#if DEBUG
import Foundation
import SalemoveSDK

extension CoreSdkClient {
    static let mock = Self(
        pushNotifications: .mock,
        createAppDelegate: { .mock },
        clearSession: {},
        fetchVisitorInfo: { _ in },
        updateVisitorInfo: { _, _ in },
        sendSelectedOptionValue: { _, _ in },
        configureWithConfiguration: { _, _ in },
        configureWithInteractor: { _ in },
        queueForEngagement: { _, _, _, _, _, _ in },
        requestMediaUpgradeWithOffer: { _, _ in },
        sendMessagePreview: { _, _ in },
        sendMessageWithAttachment: { _, _, _ in },
        cancelQueueTicket: { _, _ in },
        endEngagement: { _ in },
        requestEngagedOperator: { _ in },
        uploadFileToEngagement: { _, _, _ in },
        fetchFile: { _, _, _ in },
        getCurrentEngagement: { return nil },
        fetchSiteConfigurations: { _ in },
        submitSurveyAnswer: { _, _, _, _ in }
    )
}

extension CoreSdkClient.Operator {
    static func mock(
        id: String = "mockId",
        name: String = "Mock Operator",
        picture: SalemoveSDK.OperatorPicture? = nil,
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

extension CoreSdkClient.PushNotifications {
    static let mock = Self(applicationDidRegisterForRemoteNotificationsWithDeviceToken: { _, _ in })
}

extension CoreSdkClient.AppDelegate {
    static let mock = Self(
        applicationDidFinishLaunchingWithOptions: { _, _ in false },
        applicationDidBecomeActive: { _ in }
    )
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
    static func mock() throws -> Self {
        try .init(
            siteId: "mockSiteId",
            region: .us,
            authorizingMethod: .mock
        )
    }
}

extension CoreSdkClient.Salemove.AuthorizationMethod {
    static let mock = Self.siteApiKey(id: "mockSiteApiKeyId", secret: "mockSiteApiKeySecret")

}

extension CoreSdkClient.VisitorContext {
    static let mock = CoreSdkClient.VisitorContext(type: CoreSdkClient.ContextType.page, url: "mockUrl")
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
            muteFunc: @escaping () -> Void = {} ,
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
            pauseFunc: @escaping () -> Void = {} ,
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
#endif
