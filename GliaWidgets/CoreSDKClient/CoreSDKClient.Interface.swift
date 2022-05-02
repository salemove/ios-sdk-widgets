import SalemoveSDK
import UIKit

struct CoreSdkClient {
    var pushNotifications: PushNotifications
    var createAppDelegate: () -> AppDelegate
    var clearSession: () -> Void

    typealias FetchVisitorInfo = (_ completion: @escaping (Result<Self.Salemove.VisitorInfo, Error>) -> Void) -> Void
    var fetchVisitorInfo: FetchVisitorInfo

    typealias UpdateVisitorInfo = (
        _ info: Self.VisitorInfoUpdate,
        _ completion: @escaping (Result<Bool, Error>) -> Void
    ) -> Void
    var updateVisitorInfo: UpdateVisitorInfo

    typealias SendSelectedOptionValue = (
        _ singleChoiceOption: SingleChoiceOption,
        _ completion: @escaping (Result<Self.Message, Error>) -> Void
    ) -> Void
    var sendSelectedOptionValue: SendSelectedOptionValue

    typealias ConfigureWithConfiguration = (
        _ sdkConfiguration: Self.Salemove.Configuration,
        _ completion: (() -> Void)?
    ) -> Void
    var configureWithConfiguration: ConfigureWithConfiguration

    typealias ConfigureWithInteractor = (_ interactor: Self.Interactable) -> Void
    var configureWithInteractor: ConfigureWithInteractor

    typealias QueueForEngagement = (
        _ queueID: String,
        _ visitorContext: Self.VisitorContext,
        _ shouldCloseAllQueues: Bool,
        _ mediaType: Self.MediaType,
        _ options: Self.EngagementOptions?,
        _ completion: @escaping Self.QueueTicketBlock
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

    typealias SendMessageWithAttachment = (
        _ message: String,
        _ attachment: Self.Attachment?,
        _ completion: @escaping Self.MessageBlock
    ) -> Void
    var sendMessageWithAttachment: SendMessageWithAttachment

    typealias CancelQueueTicket = (
        _ queueTicket: Self.QueueTicket,
        _ completion: @escaping SalemoveSDK.SuccessBlock
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
}

extension CoreSdkClient {
    struct PushNotifications {
        var applicationDidRegisterForRemoteNotificationsWithDeviceToken: (
            _ application: UIApplication,
            _ deviceToken: Data
        ) -> Void
    }
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
    typealias AnswerBlock = SalemoveSDK.AnswerBlock
    typealias AnswerWithSuccessBlock = SalemoveSDK.AnswerWithSuccessBlock
    typealias Attachment = SalemoveSDK.Attachment
    typealias AttachmentType = SalemoveSDK.AttachmentType
    typealias AudioStreamable = SalemoveSDK.AudioStreamable
    typealias AudioStreamAddedBlock = SalemoveSDK.AudioStreamAddedBlock
    typealias ContextType = SalemoveSDK.ContextType
    typealias EngagementFile = SalemoveSDK.EngagementFile
    typealias EngagementFileCompletionBlock = SalemoveSDK.EngagementFileCompletionBlock
    typealias EngagementFileData = SalemoveSDK.EngagementFileData
    typealias EngagementFileFetchCompletionBlock = SalemoveSDK.EngagementFileFetchCompletionBlock
    typealias EngagementFileInformation = SalemoveSDK.EngagementFileInformation
    typealias EngagementFileProgressBlock = SalemoveSDK.EngagementFileProgressBlock
    typealias EngagementOptions = SalemoveSDK.EngagementOptions
    typealias EngagementTransferBlock = SalemoveSDK.EngagementTransferBlock
    typealias FileError = SalemoveSDK.FileError
    typealias GeneralError = SalemoveSDK.GeneralError
    typealias Interactable = SalemoveSDK.Interactable
    typealias MediaDirection = SalemoveSDK.MediaDirection
    typealias MediaError = SalemoveSDK.MediaError
    typealias MediaType = SalemoveSDK.MediaType
    typealias MediaUgradeOfferBlock = SalemoveSDK.MediaUgradeOfferBlock
    typealias MediaUpgradeOffer = SalemoveSDK.MediaUpgradeOffer
    typealias Message = SalemoveSDK.Message
    typealias MessageSender = SalemoveSDK.MessageSender
    typealias MessageBlock = SalemoveSDK.MessageBlock
    typealias MessagesUpdateBlock = SalemoveSDK.MessagesUpdateBlock
    typealias Operator = SalemoveSDK.Operator
    typealias OperatorBlock = SalemoveSDK.OperatorBlock
    typealias OperatorTypingStatus = SalemoveSDK.OperatorTypingStatus
    typealias OperatorTypingStatusUpdate = SalemoveSDK.OperatorTypingStatusUpdate
    typealias QueueError = SalemoveSDK.QueueError
    typealias QueueTicket = SalemoveSDK.QueueTicket
    typealias QueueTicketBlock = SalemoveSDK.QueueTicketBlock
    typealias RequestOfferBlock = SalemoveSDK.RequestOfferBlock
    typealias Salemove = SalemoveSDK.Salemove
    typealias SalemoveError = SalemoveSDK.SalemoveError
    typealias ScreenshareOfferBlock = SalemoveSDK.ScreenshareOfferBlock
    typealias SingleChoiceOption = SalemoveSDK.SingleChoiceOption
    typealias StreamableOnHoldHandler = SalemoveSDK.StreamableOnHoldHandler
    typealias StreamView = SalemoveSDK.StreamView
    typealias SuccessBlock = SalemoveSDK.SuccessBlock
    typealias VideoStreamable = SalemoveSDK.VideoStreamable
    typealias VideoStreamAddedBlock = SalemoveSDK.VideoStreamAddedBlock
    typealias VisitorContext = SalemoveSDK.VisitorContext
    typealias VisitorInfoUpdate = SalemoveSDK.VisitorInfoUpdate
    typealias VisitorScreenSharingState = SalemoveSDK.VisitorScreenSharingState
    typealias VisitorScreenSharingStateChange = SalemoveSDK.VisitorScreenSharingStateChange
    typealias Engagement = SalemoveSDK.Engagement
    typealias Site = SalemoveSDK.Site
    typealias EngagementTransferringBlock = SalemoveSDK.EngagementTransferringBlock
}
