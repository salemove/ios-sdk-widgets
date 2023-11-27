@_spi(GliaWidgets) import GliaCoreSDK
import UIKit
import GliaCoreDependency

struct CoreSdkClient {
    var pushNotifications: PushNotifications
    var createAppDelegate: () -> AppDelegate
    var clearSession: () -> Void
    var localeProvider: LocaleProvider

    typealias FetchVisitorInfo = (_ completion: @escaping (Result<Self.Salemove.VisitorInfo, Error>) -> Void) -> Void
    var fetchVisitorInfo: FetchVisitorInfo

    typealias UpdateVisitorInfo = (
        _ info: Self.VisitorInfoUpdate,
        _ completion: @escaping (Result<Bool, Error>) -> Void
    ) -> Void
    var updateVisitorInfo: UpdateVisitorInfo

    typealias ConfigureWithConfiguration = (
        _ sdkConfiguration: Self.Salemove.Configuration,
        _ completion: @escaping Self.ConfigureCompletion
    ) -> Void
    var configureWithConfiguration: ConfigureWithConfiguration

    typealias ConfigureWithInteractor = (_ interactor: Self.Interactable) -> Void
    var configureWithInteractor: ConfigureWithInteractor

    typealias ListQueues = (
        _ completion: @escaping Self.QueueRequestBlock
    ) -> Void
    var listQueues: ListQueues

    typealias QueueForEngagement = (
        _ options: GliaCoreSDK.QueueForEngagementOptions,
        _ completion: @escaping (Result<GliaCoreSDK.QueueTicket, GliaCoreSDK.GliaCoreError>) -> Void
    ) -> Void
    var queueForEngagement: QueueForEngagement

    typealias RequestMediaUpgradeWithOffer = (
        _ offer: Self.MediaUpgradeOffer,
        _ completion: @escaping Self.SuccessBlock
    ) -> Void
    var requestMediaUpgradeWithOffer: RequestMediaUpgradeWithOffer

    typealias SendMessagePreview = (
        _ message: String,
        _ completion: @escaping Self.SuccessBlock
    ) -> Void
    var sendMessagePreview: SendMessagePreview

    typealias SendMessageWithMessagePayloadCallback = (Result<CoreSdkClient.Message, CoreSdkClient.GliaCoreError>) -> Void
        typealias SendMessageWithMessagePayload = (
            _ sendMessagePayload: Self.SendMessagePayload,
            _ completion: @escaping SendMessageWithMessagePayloadCallback
        ) -> Void
    var sendMessageWithMessagePayload: SendMessageWithMessagePayload

    typealias CancelQueueTicket = (
        _ queueTicket: Self.QueueTicket,
        _ completion: @escaping GliaCoreSDK.SuccessBlock
    ) -> Void
    var cancelQueueTicket: CancelQueueTicket

    typealias EndEngagement = (_ completion: @escaping Self.SuccessBlock) -> Void
    var endEngagement: EndEngagement

    typealias RequestEngagedOperator = (_ completion: @escaping Self.OperatorBlock) -> Void
    var requestEngagedOperator: RequestEngagedOperator

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

    typealias RequestVisitorCode = (_ completion: @escaping (VisitorCodeBlock) -> Void) -> GliaCore.Cancellable
    var requestVisitorCode: RequestVisitorCode

    typealias SendSecureMessagePayload = (
        _ secureMessagePayload: SendMessagePayload,
        _ queueIds: [String],
        _ completion: @escaping (Result<Self.Message, Error>) -> Void
    ) -> Self.Cancellable
    var sendSecureMessagePayload: SendSecureMessagePayload

    typealias SecureConversationsUploadFile = (
        _ file: EngagementFile,
        _ progress: EngagementFileProgressBlock?,
        _ completion: @escaping (Result<EngagementFileInformation, Swift.Error>) -> Void
    ) -> Self.Cancellable
    var uploadSecureFile: SecureConversationsUploadFile

    typealias GetSecureUnreadMessageCount = (_ callback: @escaping (Result<Int, Error>) -> Void) -> Void
    var getSecureUnreadMessageCount: GetSecureUnreadMessageCount

    typealias SecureMarkMessagesAsRead = (_ callback: @escaping (Result<Void, Error>) -> Void) -> Cancellable
    var secureMarkMessagesAsRead: SecureMarkMessagesAsRead

    typealias DownloadSecureFile = (
        _ file: EngagementFile,
        _ progress: @escaping EngagementFileProgressBlock,
        _ completion: @escaping (Result<EngagementFileData, Error>) -> Void
    ) -> Cancellable

    var downloadSecureFile: DownloadSecureFile

    typealias StartSocketObservation = () -> Void
    var startSocketObservation: StartSocketObservation

    typealias StopSocketObservation = () -> Void
    var stopSocketObservation: StopSocketObservation

    typealias CreateSendMessagePayload = (_ content: String, _ attachment: Attachment?) -> SendMessagePayload
    var createSendMessagePayload: CreateSendMessagePayload

    typealias CreateLogger = ([String: String]) throws -> Logger
    var createLogger: CreateLogger
}

extension CoreSdkClient {
    struct PushNotifications {
        var applicationDidRegisterForRemoteNotificationsWithDeviceToken: (
            _ application: UIApplication,
            _ deviceToken: Data
        ) -> Void

        var setPushHandler: (PushHandler?) -> Void
        var pushHandler: () -> PushHandler?
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
        typealias CustomLocaleGetRemoteString = ((String) -> String?)
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
    typealias Queue = GliaCoreSDK.Queue
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
    typealias ScreenshareOfferBlock = GliaCoreSDK.ScreenshareOfferBlock
    typealias SingleChoiceOption = GliaCoreSDK.SingleChoiceOption
    typealias StreamableOnHoldHandler = GliaCoreSDK.StreamableOnHoldHandler
    typealias StreamView = GliaCoreSDK.StreamView
    typealias SuccessBlock = GliaCoreSDK.SuccessBlock
    typealias VideoStreamable = GliaCoreSDK.VideoStreamable
    typealias VideoStreamAddedBlock = GliaCoreSDK.VideoStreamAddedBlock
    typealias VisitorContext = GliaCoreSDK.VisitorContext
    typealias ContextType = GliaCoreSDK.VisitorContext.ContextType
    typealias VisitorInfoUpdate = GliaCoreSDK.VisitorInfoUpdate
    typealias VisitorScreenSharingState = GliaCoreSDK.VisitorScreenSharingState
    typealias VisitorScreenSharingStateChange = GliaCoreSDK.VisitorScreenSharingStateChange
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
}
