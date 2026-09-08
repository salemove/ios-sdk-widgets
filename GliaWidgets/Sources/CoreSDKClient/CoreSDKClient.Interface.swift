@_spi(GliaWidgets) internal import GliaCoreSDK
import Combine
import UIKit
import GliaCoreDependency

struct CoreSdkClient {
    var pushNotifications: PushNotifications
    var liveObservation: LiveObservation
    var secureConversations: SecureConversations
    var clearSession: () -> Void
    var localeProvider: LocaleProvider
    @Dependency(\.widgets.networkMonitor) var networkConnectionMonitor: NetworkConnectionMonitor
    @Dependency(\.widgets.callQualityMonitor) var callQualityMonitor: CallQualityMonitor
    var configureWithConfiguration: ConfigureWithConfiguration
    var getVisitorInfo: () async throws -> VisitorInfo
    var updateVisitorInfo: (VisitorInfoUpdate) async throws -> Bool
    var configureWithInteractor: ConfigureWithInteractor
    var getQueues: GetQueues
    var queueForEngagement: QueueForEngagement
    var sendMessagePreview: (_ message: String) async throws -> Bool
    var sendMessageWithMessagePayload: (_ payload: SendMessagePayload) async throws -> Message
    var cancelQueueTicket: CancelQueueTicket
    var endEngagement: () async throws -> Bool
    var requestEngagedOperator: () async throws -> [GliaCoreSDK.Operator]?
    var uploadFileToEngagement: UploadFileToEngagement
    var fetchFile: FetchFile
    var getCurrentEngagement: GetCurrentEngagement
    var fetchSiteConfigurations: FetchSiteConfigurations
    var submitSurveyAnswer: SubmitSurveyAnswer
    var authentication: CreateAuthentication
    var fetchChatHistory: FetchChatHistory
    var requestVisitorCode: RequestVisitorCode
    var startSocketObservation: StartSocketObservation
    var stopSocketObservation: StopSocketObservation
    var createSendMessagePayload: CreateSendMessagePayload
    var createLogger: CreateLogger
    var getCameraDeviceManageable: GetCameraDeviceManageable
    var subscribeForQueuesUpdates: SubscribeForQueuesUpdates
    var configureLogLevel: (LogLevel) -> Void
}

extension CoreSdkClient {
    typealias ConfigureWithConfiguration = (
        _ sdkConfiguration: GliaCore.Configuration
    ) async throws -> Void

    typealias ConfigureWithInteractor = (_ interactor: Interactable) -> Void
    typealias GetQueues = () async throws -> [Queue]
    typealias QueueForEngagement = (
        _ options: QueueForEngagementOptions,
        _ replaceExisting: Bool
    ) async throws -> QueueTicket
    typealias CancelQueueTicket = (_ queueTicket: QueueTicket) async throws -> Bool
    typealias UploadFileToEngagement = (
        _ file: EngagementFile,
        _ progress: EngagementFileProgressBlock?
    ) async throws -> EngagementFileInformation
    typealias FetchFile = (
        _ engagementFile: EngagementFile,
        _ progress: EngagementFileProgressBlock?
    ) async throws -> EngagementFileData

    typealias GetCurrentEngagement = () -> Engagement?
    typealias FetchSiteConfigurations = () async throws -> Site
    typealias SubmitSurveyAnswer = (
        (
            _ answers: [GliaCoreSDK.Survey.Answer],
            _ surveyId: GliaCoreSDK.Survey.Id,
            _ engagementId: String
        ) async throws -> Void
    )
    typealias CreateAuthentication = (_ behaviour: AuthenticationBehavior) throws -> Authentication
    typealias FetchChatHistory = () async throws -> [ChatMessage]
    typealias RequestVisitorCode = () async throws -> VisitorCode
    typealias StartSocketObservation = () -> Void
    typealias StopSocketObservation = () -> Void
    typealias CreateSendMessagePayload = (_ content: String, _ attachment: Attachment?) -> SendMessagePayload
    typealias CreateLogger = ([String: String]) throws -> Logger
    typealias GetCameraDeviceManageable = () throws -> CameraDeviceManageableClient
    typealias SubscribeForQueuesUpdates = (_ queueIds: [String]) -> AsyncThrowingStream<Queue, Error>
}

extension CoreSdkClient {
    struct SecureConversations {
        var sendMessagePayload: SendPayload
        var uploadFile: UploadFile
        var getUnreadMessageCount: GetUnreadMessageCount
        var markMessagesAsRead: MarkMessagesAsRead
        var downloadFile: DownloadFile
        var subscribeForUnreadMessageCount: SubscribeForUnreadMessageCount
        var observePendingStatus: ObservePendingStatus
    }
}

extension CoreSdkClient.SecureConversations {
    typealias Cancellable = GliaCore.Cancellable

    typealias Message = GliaCoreSDK.Message

    typealias SendPayload = (
        _ secureMessagePayload: SendMessagePayload,
        _ queueIds: [String]
    ) async throws -> Message

    typealias UploadFile = (
        _ file: EngagementFile,
        _ progress: EngagementFileProgressBlock?
    ) async throws -> EngagementFileInformation

    typealias GetUnreadMessageCount = () async throws -> Int

    typealias MarkMessagesAsRead = () async throws -> Void

    typealias DownloadFile = (
        _ file: EngagementFile,
        _ progress: @escaping EngagementFileProgressBlock
    ) async throws -> CoreSdkClient.EngagementFileData

    typealias SubscribeForUnreadMessageCount = () throws -> AsyncThrowingStream<Int?, Error>

    typealias ObservePendingStatus = () throws -> AsyncThrowingStream<Bool, Error>
}

extension CoreSdkClient {
    struct LiveObservation {
        var pause: () -> Void
        var resume: () -> Void
    }
}

extension CoreSdkClient {
    struct PushNotifications {
        struct Actions {
            var setSecureMessageAction: (@escaping (_ senderQueueId: String?) -> Void) -> Void
            var secureMessageAction: () -> ((_ senderQueueId: String?) -> Void)?

            init(
                setSecureMessageAction: @escaping (@escaping (_ senderQueueId: String?) -> Void) -> Void,
                secureMessageAction: @escaping () -> ((_ senderQueueId: String?) -> Void)?
            ) {
                self.setSecureMessageAction = setSecureMessageAction
                self.secureMessageAction = secureMessageAction
            }
        }

        var applicationDidRegisterForRemoteNotificationsWithDeviceToken: (
            _ application: UIApplication,
            _ deviceToken: Data
        ) -> Void
        var applicationDidFailToRegisterForRemoteNotificationsWithError: (
            _ application: UIApplication,
            _ error: any Error
        ) -> Void
        var setPushHandler: (PushActionBlock?) -> Void
        var subscribeTo: ([PushNotificationsType]) -> Void
        var actions: Actions
        var userNotificationCenterWillPresent: (
            _ center: UNUserNotificationCenter,
            _ willPresentNotification: UNNotification,
            _ completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) -> Void
        var userNotificationCenterDidReceiveResponse: (
            _ center: UNUserNotificationCenter,
            _ didReceiveResponse: UNNotificationResponse,
            _ completionHandler: @escaping () -> Void
        ) -> Void
    }
}

extension CoreSdkClient {
    struct LocaleProvider {
        typealias CustomLocaleGetRemoteString = (String) -> String?

        var getRemoteString: CustomLocaleGetRemoteString
    }
}

extension CoreSdkClient {
    typealias AnswerWithSuccessBlock = GliaCoreSDK.AnswerWithSuccessBlock
    typealias Attachment = GliaCoreSDK.Attachment
    typealias AttachmentType = GliaCoreSDK.AttachmentType
    typealias AudioStreamable = GliaCoreSDK.AudioStreamable
    typealias AudioStreamAddedBlock = GliaCoreSDK.AudioStreamAddedBlock
    typealias CameraDevice = GliaCoreSDK.CameraDevice
    typealias EngagementFile = GliaCoreSDK.EngagementFile
    typealias EngagementFileInformation = GliaCoreSDK.EngagementFileInformation
    typealias EngagementFileProgressBlock = GliaCoreSDK.EngagementFileProgressBlock
    typealias EngagementOptions = GliaCoreSDK.EngagementOptions
    typealias EngagementTransferBlock = GliaCoreSDK.EngagementTransferBlock
    typealias EngagementTransferringBlock = GliaCoreSDK.EngagementTransferringBlock
    typealias FileError = GliaCoreSDK.FileError
    typealias GeneralError = GliaCoreSDK.GeneralError
    typealias GliaCoreError = GliaCoreSDK.GliaCoreError
    typealias ConfigurationProcessError = GliaCoreSDK.GliaCore.ConfigurationProcessError
    typealias Configuration = GliaCore.Configuration
    typealias Interactable = GliaCoreSDK.Interactable
    typealias MediaDirection = GliaCoreSDK.MediaDirection
    typealias MediaType = GliaCoreSDK.MediaType
    typealias MediaUgradeOfferBlock = GliaCoreSDK.MediaUgradeOfferBlock
    typealias MediaUpgradeOffer = GliaCoreSDK.MediaUpgradeOffer
    typealias MediaUpdateBlock = GliaCoreSDK.MediaUpdateBlock
    typealias Message = GliaCoreSDK.Message
    typealias MessageSender = GliaCoreSDK.MessageSender
    typealias MessagesUpdateBlock = GliaCoreSDK.MessagesUpdateBlock
    typealias Operator = GliaCoreSDK.Operator
    typealias OperatorPicture = GliaCoreSDK.OperatorPicture
    typealias OperatorTypingStatus = GliaCoreSDK.OperatorTypingStatus
    typealias OperatorTypingStatusUpdate = GliaCoreSDK.OperatorTypingStatusUpdate
    typealias CoreQueue = GliaCoreSDK.Queue
    typealias QueueError = GliaCoreSDK.QueueError
    typealias QueueTicket = GliaCoreSDK.QueueTicket
    typealias RequestOfferBlock = GliaCoreSDK.RequestOfferBlock
    typealias SalemoveError = GliaCoreSDK.GliaCoreError
    typealias SingleChoiceOption = GliaCoreSDK.SingleChoiceOption
    typealias StreamableOnHoldHandler = GliaCoreSDK.StreamableOnHoldHandler
    typealias StreamView = GliaCoreSDK.StreamView
    typealias SuccessBlock = GliaCoreSDK.SuccessBlock
    typealias VideoStreamable = GliaCoreSDK.VideoStreamable
    typealias VideoStreamAddedBlock = GliaCoreSDK.VideoStreamAddedBlock
    typealias VisitorContext = GliaCoreSDK.VisitorContext
    typealias Engagement = GliaCoreSDK.Engagement
    typealias Site = GliaCoreSDK.Site
    typealias Survey = GliaCoreSDK.Survey
    typealias SurveyAnswerContainer = GliaCoreSDK.Survey.Answer.ValueContainer
    typealias Authentication = GliaCoreSDK.GliaCore.Authentication
    typealias AuthenticationBehavior = GliaCoreSDK.GliaCore.Authentication.Behavior
    typealias EngagementEndingReason = GliaCoreSDK.EngagementEndingReason
    typealias Cancellable = GliaCore.Cancellable
    typealias SendMessagePayload = GliaCoreSDK.SendMessagePayload
    typealias Request = GliaCoreSDK.Request
    typealias EngagementChangedBlock = GliaCoreSDK.EngagementChangedBlock
    typealias QueueForEngagementOptions = GliaCoreSDK.QueueForEngagementOptions
    typealias Region = GliaCore.Region
    typealias AuthorizationMethod = GliaCore.AuthorizationMethod
    typealias VisitorCode = GliaCoreSDK.VisitorCode
    typealias Tagged = GliaCoreSDK.Tagged
    typealias CoreVisitorInfo = GliaCore.VisitorInfo
    typealias CoreVisitorInfoUpdate = GliaCoreSDK.VisitorInfoUpdate
    typealias AnyCodable = GliaCoreSDK.AnyCodable
    typealias NetworkStatus = GliaCoreSDK.NetworkConnectionMonitor.NetworkStatus
    typealias DisposableBag = GliaCoreSDK.DisposableBag
    typealias TaskDisposable = GliaCoreSDK.TaskDisposable
    typealias MediaQuality = GliaCoreSDK.MediaQuality
}

extension CoreSdkClient {
    struct AnyScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        private let nowClosure: () -> SchedulerTimeType
        private let minimumToleranceClosure: () -> SchedulerTimeType.Stride
        private let scheduleClosure: (SchedulerOptions?, @escaping () -> Void) -> Void
        private let scheduleAfterClosure: (
            SchedulerTimeType,
            SchedulerTimeType.Stride,
            SchedulerOptions?,
            @escaping () -> Void
        ) -> Void
        private let scheduleAfterIntervalClosure: (
            SchedulerTimeType,
            SchedulerTimeType.Stride,
            SchedulerTimeType.Stride,
            SchedulerOptions?,
            @escaping () -> Void
        ) -> any Combine.Cancellable

        var now: SchedulerTimeType { nowClosure() }
        var minimumTolerance: SchedulerTimeType.Stride { minimumToleranceClosure() }

        init<S: Scheduler>(_ scheduler: S) where S.SchedulerTimeType == SchedulerTimeType,
                                                S.SchedulerOptions == SchedulerOptions {
            nowClosure = { scheduler.now }
            minimumToleranceClosure = { scheduler.minimumTolerance }
            scheduleClosure = { options, action in scheduler.schedule(options: options, action) }
            scheduleAfterClosure = { date, tolerance, options, action in
                scheduler.schedule(after: date, tolerance: tolerance, options: options, action)
            }
            scheduleAfterIntervalClosure = { date, interval, tolerance, options, action in
                scheduler.schedule(
                    after: date,
                    interval: interval,
                    tolerance: tolerance,
                    options: options,
                    action
                )
            }
        }

        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            scheduleClosure(options, action)
        }

        func schedule(
            after date: SchedulerTimeType,
            tolerance: SchedulerTimeType.Stride,
            options: SchedulerOptions?,
            _ action: @escaping () -> Void
        ) {
            scheduleAfterClosure(date, tolerance, options, action)
        }

        func schedule(
            after date: SchedulerTimeType,
            interval: SchedulerTimeType.Stride,
            tolerance: SchedulerTimeType.Stride,
            options: SchedulerOptions?,
            _ action: @escaping () -> Void
        ) -> any Combine.Cancellable {
            scheduleAfterIntervalClosure(date, interval, tolerance, options, action)
        }
    }

    struct ImmediateScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        var now: SchedulerTimeType { DispatchQueue.main.now }
        var minimumTolerance: SchedulerTimeType.Stride { .zero }

        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            action()
        }

        func schedule(
            after date: SchedulerTimeType,
            tolerance: SchedulerTimeType.Stride,
            options: SchedulerOptions?,
            _ action: @escaping () -> Void
        ) {
            action()
        }

        func schedule(
            after date: SchedulerTimeType,
            interval: SchedulerTimeType.Stride,
            tolerance: SchedulerTimeType.Stride,
            options: SchedulerOptions?,
            _ action: @escaping () -> Void
        ) -> any Combine.Cancellable {
            action()
            return AnyCancellable {}
        }
    }

    struct AnyCombineScheduler {
        let mainScheduler: AnyScheduler
        let globalScheduler: AnyScheduler

        var main: AnyScheduler { mainScheduler }
        var global: AnyScheduler { globalScheduler }

        static let live = Self(
            mainScheduler: AnyScheduler(DispatchQueue.main),
            globalScheduler: AnyScheduler(DispatchQueue.global(qos: .default))
        )

        static let mock = Self(
            mainScheduler: AnyScheduler(ImmediateScheduler()),
            globalScheduler: AnyScheduler(ImmediateScheduler())
        )
    }
}

extension AnyPublisher {
    static func mock<T>() -> AnyPublisher<T, Never> {
        Empty().eraseToAnyPublisher()
    }

    static func mock<T>(_ value: T) -> AnyPublisher<T, Never> {
        Just(value).eraseToAnyPublisher()
    }
}

extension CoreSdkClient {
    struct CameraDeviceManageableClient {
        var setCameraDevice: (_ cameraDevice: GliaCoreSDK.CameraDevice) -> Void
        var cameraDevices: () -> [GliaCoreSDK.CameraDevice]
        var currentCameraDevice: () -> GliaCoreSDK.CameraDevice?
    }
}

extension CoreSdkClient.MediaType {
    init(engagementKind: EngagementKind) {
        switch engagementKind {
        case .none:
            self = .unknown
        case .chat:
            self = .text
        case .audioCall:
            self = .audio
        case .videoCall:
            self = .video
        case .messaging:
            self = .messaging
        }
    }
}

extension CoreSdkClient {
    // Used to get current engagement except the case,
    // when engagement is transferred Secure Conversation,
    // which nature is similar to a Queue Ticket.
    var getNonTransferredSecureConversationEngagement: GetCurrentEngagement {
      {
        let engagement = getCurrentEngagement()
        return engagement?.isTransferredSecureConversation == true ? nil : engagement
      }
    }
}

extension CoreSdkClient.Engagement {
    var isTransferredSecureConversation: Bool {
        Self.isTransferredSecureConversation(self)
    }
}

extension CoreSdkClient {
    struct NetworkConnectionMonitor {
        var networkStream: (Bool) -> AsyncStream<NetworkStatus>
    }
}

typealias NetworkConnectionMonitor = CoreSdkClient.NetworkConnectionMonitor

extension CoreSdkClient.NetworkConnectionMonitor {
    static let live: Self = .init(
        networkStream: { replay in
            GliaCore.sharedInstanceForWidgets.networkConnectionMonitor.networkStreamForWidgets(replay: replay)
        }
    )

    struct Key: DependencyKey {
        static var live: NetworkConnectionMonitor = .live

        static var test: NetworkConnectionMonitor = .init(networkStream: { _ in
            AsyncStream { continuation in
                continuation.finish()
            }
        })
    }
}
extension DependencyContainer.Widgets {
    var networkMonitor: NetworkConnectionMonitor {
        get { self[NetworkConnectionMonitor.Key.self] }
        set { self[NetworkConnectionMonitor.Key.self] = newValue }
    }
}

extension CoreSdkClient {
    struct CallQualityMonitor {
        var mediaQualityStream: () -> AsyncStream<MediaQuality>
    }
}

typealias CallQualityMonitor = CoreSdkClient.CallQualityMonitor

extension CoreSdkClient.CallQualityMonitor {
    static let live: Self = .init(
        mediaQualityStream: {
            GliaCore.sharedInstanceForWidgets.callQualityMonitor.mediaQualityStreamForWidgets()
        }
    )

    struct Key: DependencyKey {
        static var live: CallQualityMonitor = .live

        static var test: CallQualityMonitor = .init(mediaQualityStream: {
            AsyncStream { continuation in
                continuation.finish()
            }
        })
    }
}
extension DependencyContainer.Widgets {
    var callQualityMonitor: CallQualityMonitor {
        get { self[CallQualityMonitor.Key.self] }
        set { self[CallQualityMonitor.Key.self] = newValue }
    }
}

typealias DependencyContainer = GliaCoreSDK.DependencyContainer
