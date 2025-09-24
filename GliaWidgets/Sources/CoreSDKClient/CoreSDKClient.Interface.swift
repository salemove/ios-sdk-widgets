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
    var unsubscribeFromUpdates: UnsubscribeFromUpdates
    var configureLogLevel: (LogLevel) -> Void
}

extension CoreSdkClient {
    typealias ConfigureWithConfiguration = (
        _ sdkConfiguration: GliaCore.Configuration,
        _ completion: @escaping ConfigureCompletion
    ) -> Void

    typealias ConfigureWithInteractor = (_ interactor: Interactable) -> Void
    typealias GetQueues = () async throws -> [Queue]
    typealias QueueForEngagement = (
        _ options: QueueForEngagementOptions,
        _ replaceExisting: Bool
    ) async throws -> QueueTicket
    typealias CancelQueueTicket = (_ queueTicket: QueueTicket) async throws -> Bool
    typealias UploadFileToEngagement = (
        _ file: EngagementFile,
        _ progress: EngagementFileProgressBlock?,
        _ completion: @escaping EngagementFileCompletionBlock
    ) -> Void
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
    typealias SubscribeForQueuesUpdates = (
        _ queueIds: [String],
        _ completion: @escaping (Result<Queue, Error>) -> Void
    ) -> String?
    typealias UnsubscribeFromUpdates = (
        _ queueCallbackId: String,
        _ onError: @escaping (GliaCoreSDK.GliaCoreError) -> Void
    ) -> Void
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
        var observePendingStatus: ObservePendingStatus
        var unsubscribeFromPendingStatus: UnsubscribeFromPendingStatus
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
        _ progress: EngagementFileProgressBlock?,
        _ completion: @escaping (Result<EngagementFileInformation, Swift.Error>) -> Void
    ) -> Cancellable

    typealias GetUnreadMessageCount = () async throws -> Int

    typealias MarkMessagesAsRead = () async throws -> Void

    typealias DownloadFile = (
        _ file: EngagementFile,
        _ progress: @escaping EngagementFileProgressBlock
    ) async throws -> EngagementFileData

    typealias SubscribeForUnreadMessageCount = (
        _ completion: @escaping (Result<Int?, Error>) -> Void
    ) -> String?

    typealias UnsubscribeFromUnreadCount = (String) -> Void

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
    typealias AnswerWithSuccessBlock = GliaCoreSDK.AnswerWithSuccessBlock
    typealias Attachment = GliaCoreSDK.Attachment
    typealias AttachmentType = GliaCoreSDK.AttachmentType
    typealias AudioStreamable = GliaCoreSDK.AudioStreamable
    typealias AudioStreamAddedBlock = GliaCoreSDK.AudioStreamAddedBlock
    typealias CameraDevice = GliaCoreSDK.CameraDevice
    typealias EngagementFile = GliaCoreSDK.EngagementFile
    typealias EngagementFileCompletionBlock = GliaCoreSDK.EngagementFileCompletionBlock
    typealias EngagementFileData = GliaCoreSDK.EngagementFileData
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
//    typealias GliaCore = GliaCoreSDK.GliaCore
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
    typealias ReactiveSwift = GliaCoreDependency.ReactiveSwift
    typealias SendMessagePayload = GliaCoreSDK.SendMessagePayload
    typealias ConfigureCompletion = GliaCoreSDK.GliaCore.ConfigureCompletion
    typealias Logging = GliaCoreSDK.Logging
    typealias LogLevel = GliaCoreSDK.LogLevel
    typealias Request = GliaCoreSDK.Request
    typealias EngagementChangedBlock = GliaCoreSDK.EngagementChangedBlock
    typealias AnyCombineScheduler = GliaCoreSDK.AnyCombineScheduler
    typealias AnyScheduler = GliaCoreSDK.AnyScheduler
    typealias QueueForEngagementOptions = GliaCoreSDK.QueueForEngagementOptions
    typealias Region = GliaCore.Region
    typealias AuthorizationMethod = GliaCore.AuthorizationMethod
    typealias VisitorCode = GliaCoreSDK.VisitorCode
    typealias Tagged = GliaCoreSDK.Tagged
    typealias CoreVisitorInfo = GliaCore.VisitorInfo
    typealias CoreVisitorInfoUpdate = GliaCoreSDK.VisitorInfoUpdate
    typealias AnyCodable = GliaCoreSDK.AnyCodable
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
