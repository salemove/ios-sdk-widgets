import SalemoveSDK
import UIKit

struct CoreSdkClient {
    var pushNotifications: PushNotifications
    var createAppDelegate: () -> AppDelegate
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
    typealias EngagementFile = SalemoveSDK.EngagementFile
    typealias EngagementFileCompletionBlock = SalemoveSDK.EngagementFileCompletionBlock
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
    typealias MessagesUpdateBlock = SalemoveSDK.MessagesUpdateBlock
    typealias Operator = SalemoveSDK.Operator
    typealias OperatorTypingStatus = SalemoveSDK.OperatorTypingStatus
    typealias OperatorTypingStatusUpdate = SalemoveSDK.OperatorTypingStatusUpdate
    typealias QueueError = SalemoveSDK.QueueError
    typealias QueueTicket = SalemoveSDK.QueueTicket
    typealias RequestOfferBlock = SalemoveSDK.RequestOfferBlock
    typealias Salemove = SalemoveSDK.Salemove
    typealias SalemoveError = SalemoveSDK.SalemoveError
    typealias ScreenshareOfferBlock = SalemoveSDK.ScreenshareOfferBlock
    typealias SingleChoiceOption = SalemoveSDK.SingleChoiceOption
    typealias StreamView = SalemoveSDK.StreamView
    typealias VideoStreamable = SalemoveSDK.VideoStreamable
    typealias VideoStreamAddedBlock = SalemoveSDK.VideoStreamAddedBlock
    typealias VisitorContext = SalemoveSDK.VisitorContext
    typealias VisitorScreenSharingState = SalemoveSDK.VisitorScreenSharingState
    typealias VisitorScreenSharingStateChange = SalemoveSDK.VisitorScreenSharingStateChange
}
