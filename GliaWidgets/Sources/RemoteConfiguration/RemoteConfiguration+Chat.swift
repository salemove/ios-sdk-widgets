import Foundation

extension RemoteConfiguration {
    final class Chat: Codable {
        let background: Layer?
        let header: Header?
        let connect: EngagementStates?
        let operatorMessage: MessageBalloon?
        let visitorMessage: MessageBalloon?
        let input: Input?
        let inputDisabled: Input?
        let responseCard: ResponseCard?
        let audioUpgrade: Upgrade?
        let videoUpgrade: Upgrade?
        let bubble: Bubble?
        let attachmentSourceList: AttachmentSourceList?
        let unreadIndicator: UnreadIndicator?
        let typingIndicator: Color?
        let newMessagesDividerColor: Color?
        let newMessagesDividerText: Text?
        let systemMessage: MessageBalloon?
        let gva: Gva?
        let secureMessaging: SecureConversations?
    }

    final class Gva: Codable {
        let persistentButton: GvaPersistentButton?
        let quickReplyButton: Button?
        let galleryCard: GvaGalleryCards?
    }

    final class GvaPersistentButton: Codable {
        let title: Text?
        let background: Layer?
        let button: Button?
    }

    final class GvaGalleryCards: Codable {
        let operatorImage: UserImageStyle?
        let cardStyle: GVAGalleryCardStyle?
    }

    final class GVAGalleryCardStyle: Codable {
        let cardContainer: Layer?
        let imageView: Layer?
        let title: Text?
        let subtitle: Text?
        let button: Button?
    }

    final class Header: Codable {
        let background: Layer?
        let text: Text?
        let backButton: Button?
        let closeButton: Button?
        let endButton: Button?
    }

    final class MessageBalloon: Codable {
        let background: Layer?
        let text: Text?
        let file: FileMessage?
        let status: Text?
        let error: Text?
        let userImage: UserImageStyle?
    }

    final class FileMessage: Codable {
        let preview: FilePreview?
        let download: FileState?
        let downloading: FileState?
        let downloaded: FileState?
        let error: FileErrorState?
        let progress: Color?
        let errorProgress: Color?
        let progressBackground: Color?
        let background: Color?
        let border: Color?
    }

    final class EngagementStates: Codable {
        let `operator`: Operator?
        let queue: EngagementState?
        let connecting: EngagementState?
        let connected: EngagementState?
        let transferring: EngagementState?
        let onHold: EngagementState?
    }

    final class EngagementState: Codable {
        let title: Text?
        let description: Text?
    }

    final class Operator: Codable {
        let image: UserImageStyle?
        let animationColor: Color?
        let onHoldOverlay: OnHoldOverlayStyle?
    }

    final class Input: Codable {
        let text: Text?
        let placeholder: Text?
        let separator: Color?
        let sendButton: Button?
        let mediaButton: Button?
        let background: Layer?
        let fileUploadBar: FileUploadBar?
    }

    final class ResponseCard: Codable {
        let background: Layer?
        let option: ResponseCardOption?
        let text: Text?
        let userImage: UserImageStyle?
    }

    final class ResponseCardOption: Codable {
        let normal: Button?
        let selected: Button?
        let disabled: Button?
    }

    final class Upgrade: Codable {
        let text: Text?
        let description: Text?
        let iconColor: Color?
        let background: Layer?
    }

    final class AttachmentSourceList: Codable {
        let items: [AttachmentSource]?
        let separator: Color?
        let background: Color?
    }

    final class AttachmentSource: Codable {
        let type: AttachmentSourceType
        let text: Text?
        let tintColor: Color?
    }

    enum AttachmentSourceType: String, Codable {
        case photoLibrary, takePhoto, browse
    }

    final class FileUploadBar: Codable {
        let filePreview: FilePreview?
        let uploading: FileState?
        let uploaded: FileState?
        let error: FileState?
        let progress: Color?
        let errorProgress: Color?
        let progressBackground: Color?
        let removeButton: Color?
    }

    final class FilePreview: Codable {
        let text: Text?
        let errorIcon: Color?
        let background: Layer?
        let errorBackground: Layer?
    }

    final class FileState: Codable {
        let text: Text?
        let info: Text?
    }

    final class FileErrorState: Codable {
        let text: Text?
        let info: Text?
        let separator: Text?
        let retry: Text?
    }

    final class UnreadIndicator: Codable {
        let backgroundColor: Color?
        let bubble: Bubble?
    }
}
