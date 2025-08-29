@_spi(GliaWidgets) import GliaCoreSDK
import UIKit
import GliaCoreDependency

struct CoreSdkClient {
    var pushNotifications: PushNotifications
    var liveObservation: LiveObservation
    var secureConversations: SecureConversations
    var createAppDelegate: () -> AppDelegate
    var clearSession: () -> Void
    var localeProvider: LocaleProvider

    typealias ConfigureWithConfiguration = (
        _ sdkConfiguration: Self.Salemove.Configuration,
        _ completion: @escaping Self.ConfigureCompletion
    ) -> Void

    var configureWithConfiguration: ConfigureWithConfiguration
    var getVisitorInfo: () async throws -> VisitorInfo
    var updateVisitorInfo: (VisitorInfoUpdate) async throws -> Bool

    typealias ConfigureWithInteractor = (_ interactor: Self.Interactable) -> Void

    var configureWithInteractor: ConfigureWithInteractor

    typealias GetQueues = (
        _ completion: @escaping (Result<[Queue], Error>) -> Void
    ) -> Void

    var getQueues: GetQueues

    typealias QueueForEngagement = (
        _ options: GliaCoreSDK.QueueForEngagementOptions,
        _ replaceExisting: Bool
    ) async throws -> GliaCoreSDK.QueueTicket

    var queueForEngagement: QueueForEngagement

    var sendMessagePreview: (_ message: String) async throws -> Bool
    var sendMessageWithMessagePayload: (_ payload: SendMessagePayload) async throws -> Message

    typealias CancelQueueTicket = (_ queueTicket: Self.QueueTicket) async throws -> Bool

    var cancelQueueTicket: CancelQueueTicket

    var endEngagement: () async throws -> Bool
    var requestEngagedOperator: () async throws -> [GliaCoreSDK.Operator]?

    typealias UploadFileToEngagement = (
        _ file: Self.EngagementFile,
        _ progress: Self.EngagementFileProgressBlock?,
        _ completion: @escaping Self.EngagementFileCompletionBlock
    ) -> Void

    var uploadFileToEngagement: UploadFileToEngagement

    typealias FetchFile = (
        _ engagementFile: Self.EngagementFile,
        _ progress: Self.EngagementFileProgressBlock?,
        _ completion: @escaping Self.EngagementFileFetchCompletionBlock
    ) -> Void

    var fetchFile: FetchFile

    typealias GetCurrentEngagement = () -> Self.Engagement?

    var getCurrentEngagement: GetCurrentEngagement

    typealias FetchSiteConfigurations = (_ completion: @escaping (Result<Self.Site, Error>) -> Void) -> Void

    var fetchSiteConfigurations: FetchSiteConfigurations

    typealias SubmitSurveyAnswer = (
        (
            _ answers: [GliaCoreSDK.Survey.Answer],
            _ surveyId: GliaCoreSDK.Survey.Id,
            _ engagementId: String,
            _ completion: @escaping (Result<Void, GliaCoreSDK.GliaCoreError>) -> Void
        ) -> Void
    )

    var submitSurveyAnswer: SubmitSurveyAnswer

    typealias CreateAuthentication = (_ behaviour: AuthenticationBehavior) throws -> Authentication

    var authentication: CreateAuthentication

    typealias FetchChatHistory = (_ completion: @escaping (Result<[ChatMessage], GliaCoreSDK.GliaCoreError>) -> Void) -> Void

    var fetchChatHistory: FetchChatHistory

    typealias RequestVisitorCode = () async throws -> VisitorCode

    var requestVisitorCode: RequestVisitorCode

    typealias StartSocketObservation = () -> Void

    var startSocketObservation: StartSocketObservation

    typealias StopSocketObservation = () -> Void

    var stopSocketObservation: StopSocketObservation

    typealias CreateSendMessagePayload = (_ content: String, _ attachment: Attachment?) -> SendMessagePayload

    var createSendMessagePayload: CreateSendMessagePayload

    typealias CreateLogger = ([String: String]) throws -> Logger

    var createLogger: CreateLogger

    typealias GetCameraDeviceManageable = () throws -> CameraDeviceManageableClient

    var getCameraDeviceManageable: GetCameraDeviceManageable

    typealias SubscribeForQueuesUpdates = (
        _ queueIds: [String],
        _ completion: @escaping (Result<Queue, Error>) -> Void
    ) -> String?

    var subscribeForQueuesUpdates: SubscribeForQueuesUpdates

    typealias UnsubscribeFromUpdates = (
        _ queueCallbackId: String,
        _ onError: @escaping (GliaCoreSDK.GliaCoreError) -> Void
    ) -> Void

    var unsubscribeFromUpdates: UnsubscribeFromUpdates

    var configureLogLevel: (LogLevel) -> Void
}

extension CoreSdkClient {
    struct SecureConversations {
        var sendMessagePayload: SendPayload
        var uploadFile: UploadFile
        var getUnreadMessageCount: GetUnreadMessageCount
        var markMessagesAsRead: MarkMessagesAsRead
        var downloadFile: DownloadFile
        var subscribeForUnreadMessageCount: SubscribeForUnreadMessageCount
        var unsubscribeFromUnreadMessageCount: UnsubscribeFromUnreadCount
        var pendingStatus: PendingStatus
        var observePendingStatus: ObservePendingStatus
        var unsubscribeFromPendingStatus: UnsubscribeFromPendingStatus
    }
}

extension CoreSdkClient.SecureConversations {
    typealias Cancellable = GliaCore.Cancellable

    typealias Message = GliaCoreSDK.Message

    typealias SendPayload = (
        _ secureMessagePayload: SendMessagePayload,
        _ queueIds: [String],
        _ completion: @escaping (Result<Message, Error>) -> Void
    ) -> Cancellable

    typealias UploadFile = (
        _ file: EngagementFile,
        _ progress: EngagementFileProgressBlock?,
        _ completion: @escaping (Result<EngagementFileInformation, Swift.Error>) -> Void
    ) -> Cancellable

    typealias GetUnreadMessageCount = (_ callback: @escaping (Result<Int, Error>) -> Void) -> Void

    typealias MarkMessagesAsRead = (_ callback: @escaping (Result<Void, Error>) -> Void) -> Cancellable

    typealias DownloadFile = (
        _ file: EngagementFile,
        _ progress: @escaping EngagementFileProgressBlock,
        _ completion: @escaping (Result<EngagementFileData, Error>) -> Void
    ) -> Cancellable

    typealias SubscribeForUnreadMessageCount = (
        _ completion: @escaping (Result<Int?, Error>) -> Void
    ) -> String?

    typealias UnsubscribeFromUnreadCount = (String) -> Void

    typealias PendingStatus = (_ callback: @escaping (Result<Bool, Error>) -> Void) -> Void

    typealias ObservePendingStatus = (_ callback: @escaping (Result<Bool, Error>) -> Void) -> String?

    typealias UnsubscribeFromPendingStatus = (String) -> Void
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
        var setPushHandler: (PushHandler?) -> Void
        var pushHandler: () -> PushHandler?
        var subscribeTo: ([GliaCoreSDK.PushNotificationsType]) -> Void
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

extension CoreSdkClient.PushNotifications {
    typealias Push = GliaCoreSDK.Push
    typealias PushHandler = GliaCoreSDK.PushActionBlock
}

extension CoreSdkClient {
    struct AppDelegate {
        var applicationDidFinishLaunchingWithOptions: (
            _ application: UIApplication,
            _ launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool

        var applicationDidBecomeActive: (_ application: UIApplication) -> Void
    }
}

extension CoreSdkClient {
    struct LocaleProvider {
        typealias CustomLocaleGetRemoteString = (String) -> String?

        var getRemoteString: CustomLocaleGetRemoteString
    }
}

extension CoreSdkClient {
    typealias AnswerBlock = GliaCoreSDK.AnswerBlock
    typealias AnswerWithSuccessBlock = GliaCoreSDK.AnswerWithSuccessBlock
    typealias Attachment = GliaCoreSDK.Attachment
    typealias AttachmentType = GliaCoreSDK.AttachmentType
    typealias AudioStreamable = GliaCoreSDK.AudioStreamable
    typealias AudioStreamAddedBlock = GliaCoreSDK.AudioStreamAddedBlock
    typealias CameraDevice = GliaCoreSDK.CameraDevice
    typealias EngagementFile = GliaCoreSDK.EngagementFile
    typealias EngagementFileCompletionBlock = GliaCoreSDK.EngagementFileCompletionBlock
    typealias EngagementFileData = GliaCoreSDK.EngagementFileData
    typealias EngagementFileFetchCompletionBlock = GliaCoreSDK.EngagementFileFetchCompletionBlock
    typealias EngagementFileInformation = GliaCoreSDK.EngagementFileInformation
    typealias EngagementFileProgressBlock = GliaCoreSDK.EngagementFileProgressBlock
    typealias EngagementOptions = GliaCoreSDK.EngagementOptions
    typealias EngagementTransferBlock = GliaCoreSDK.EngagementTransferBlock
    typealias EngagementTransferringBlock = GliaCoreSDK.EngagementTransferringBlock
    typealias FileError = GliaCoreSDK.FileError
    typealias GeneralError = GliaCoreSDK.GeneralError
    typealias GliaCoreError = GliaCoreSDK.GliaCoreError
    typealias ConfigurationProcessError = GliaCoreSDK.GliaCore.ConfigurationProcessError
    typealias Interactable = GliaCoreSDK.Interactable
    typealias MediaDirection = GliaCoreSDK.MediaDirection
    typealias MediaError = GliaCoreSDK.MediaError
    typealias MediaType = GliaCoreSDK.MediaType
    typealias MediaUgradeOfferBlock = GliaCoreSDK.MediaUgradeOfferBlock
    typealias MediaUpgradeOffer = GliaCoreSDK.MediaUpgradeOffer
    typealias MediaUpdateBlock = GliaCoreSDK.MediaUpdateBlock
    typealias Message = GliaCoreSDK.Message
    typealias MessageSender = GliaCoreSDK.MessageSender
    typealias MessageBlock = GliaCoreSDK.MessageBlock
    typealias MessagesUpdateBlock = GliaCoreSDK.MessagesUpdateBlock
    typealias Operator = GliaCoreSDK.Operator
    typealias OperatorPicture = GliaCoreSDK.OperatorPicture
    typealias OperatorBlock = GliaCoreSDK.OperatorBlock
    typealias OperatorTypingStatus = GliaCoreSDK.OperatorTypingStatus
    typealias OperatorTypingStatusUpdate = GliaCoreSDK.OperatorTypingStatusUpdate
    typealias QueueError = GliaCoreSDK.QueueError
    typealias QueueState = GliaCoreSDK.QueueState
    typealias QueueStatus = GliaCoreSDK.QueueStatus
    typealias QueueRequestBlock = GliaCoreSDK.QueueRequestBlock
    typealias QueueTicket = GliaCoreSDK.QueueTicket
    typealias QueueTicketBlock = GliaCoreSDK.QueueTicketBlock
    typealias RequestOfferBlock = GliaCoreSDK.RequestOfferBlock
    typealias RequestAnswerBlock = GliaCoreSDK.RequestAnswerBlock
    typealias Salemove = GliaCoreSDK.GliaCore
    typealias SalemoveError = GliaCoreSDK.GliaCoreError
    typealias SingleChoiceOption = GliaCoreSDK.SingleChoiceOption
    typealias StreamableOnHoldHandler = GliaCoreSDK.StreamableOnHoldHandler
    typealias StreamView = GliaCoreSDK.StreamView
    typealias SuccessBlock = GliaCoreSDK.SuccessBlock
    typealias VideoScalingOptions = GliaCoreSDK.VideoScalingOptions
    typealias VideoStreamable = GliaCoreSDK.VideoStreamable
    typealias VideoStreamAddedBlock = GliaCoreSDK.VideoStreamAddedBlock
    typealias VisitorContext = GliaCoreSDK.VisitorContext
    typealias ContextType = GliaCoreSDK.VisitorContext.ContextType
    typealias Engagement = GliaCoreSDK.Engagement
    typealias Site = GliaCoreSDK.Site
    typealias Survey = GliaCoreSDK.Survey
    typealias SurveyAnswerContainer = GliaCoreSDK.Survey.Answer.ValueContainer
    typealias Authentication = GliaCoreSDK.GliaCore.Authentication
    typealias AuthenticationBehavior = GliaCoreSDK.GliaCore.Authentication.Behavior
    typealias EngagementEndingReason = GliaCoreSDK.EngagementEndingReason
    typealias VisitorCodeBlock = (Result<VisitorCode, Swift.Error>)
    typealias EngagementSource = GliaCoreSDK.EngagementSource
    typealias Cancellable = GliaCore.Cancellable
    typealias ReactiveSwift = GliaCoreDependency.ReactiveSwift
    typealias SendMessagePayload = GliaCoreSDK.SendMessagePayload
    typealias ConfigureCompletion = GliaCoreSDK.GliaCore.ConfigureCompletion
    typealias Logging = GliaCoreSDK.Logging
    typealias LogConfigurable = GliaCoreSDK.LogConfigurable
    typealias LoggingError = GliaCoreSDK.LoggingError
    typealias LogLevel = GliaCoreSDK.LogLevel
    typealias Request = GliaCoreSDK.Request
    typealias EngagementChangedBlock = GliaCoreSDK.EngagementChangedBlock
    typealias AnyCombineScheduler = GliaCoreSDK.AnyCombineScheduler
    typealias AnyScheduler = GliaCoreSDK.AnyScheduler
    typealias QueueForEngagementOptions = GliaCoreSDK.QueueForEngagementOptions
}

extension CoreSdkClient.AnyCombineScheduler {
    var main: AnyScheduler { mainScheduler }
    var global: AnyScheduler { globalScheduler }
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
