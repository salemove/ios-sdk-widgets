import Foundation

public extension RemoteConfiguration {

    struct Chat: Codable {
        public let background: Layer?
        public let header: Header?
        public let connect: EngagementStates?
        public let operatorMessage: MessageBalloon?
        public let visitorMessage: MessageBalloon?
        public let input: Input?
        public let responseCard: ResponseCard?
        public let audioUpgrade: Upgrade?
        public let videoUpgrade: Upgrade?
        public let bubble: Bubble?
        public let attachmentSourceList: AttachmentSourceList?
        public let unreadIndicator: Bubble?
        public let typingIndicator: Color?
    }

    struct Header: Codable {
        public let background: Layer?
        public let text: Text?
        public let backButton: Button?
        public let closeButton: Button?
        public let endButton: Button?
        public let endScreenSharingButton: Button?
    }

    struct MessageBalloon: Codable {
        public let alignment: [Alignment]?
        public let background: Layer?
        public let text: Text?
        public let file: FileMessage?
        public let status: Text?
        public let userImage: UserImageStyle?
    }

    struct FileMessage: Codable {
        public let preview: FilePreview?
        public let download: FileState?
        public let downloading: FileState?
        public let downloaded: FileState?
        public let error: FileErrorState?
        public let progress: Color?
        public let errorProgress: Color?
        public let progressBackground: Color?
        public let background: Color?
        public let border: Color?
    }

    struct EngagementStates: Codable {
        public let `operator`: Operator?
        public let queue: EngagementState?
        public let connecting: EngagementState?
        public let connected: EngagementState?
        public let transferring: EngagementState?
        public let onHold: EngagementState?
    }

    struct EngagementState: Codable {
        public let title: Text?
        public let description: Text?
        public let tintColor: Color?
    }

    struct Operator: Codable {
        public let image: UserImageStyle?
        public let animationColor: Color?
        public let overlayColor: Color?
    }

    struct Input: Codable {
        public let text: Text?
        public let placeholder: Text?
        public let separator: Color?
        public let sendButton: Button?
        public let mediaButton: Button?
        public let background: Layer?
        public let fileUploadBar: FileUploadBar?
    }

    struct ResponseCard: Codable {
        public let background: Layer?
        public let option: ResponseCardOption?
        public let message: MessageBalloon?
    }

    struct ResponseCardOption: Codable {
        public let normal: Button?
        public let selected: Button?
        public let disabled: Button?
    }

    struct Upgrade: Codable {
        public let text: Text?
        public let description: Text?
        public let iconColor: Color?
        public let background: Layer?
    }

    struct AttachmentSourceList: Codable {
        public let items: [AttachmentSource]?
        public let separator: Color?
        public let background: Color?
    }

    struct AttachmentSource: Codable {
        public let type: AttachmentSourceType
        public let text: Text?
        public let tintColor: Color?
    }

    enum AttachmentSourceType: String, Codable {
        case photoLibrary, takePhoto, browse
    }

    struct FileUploadBar: Codable {
        public let filePreview: FilePreview?
        public let uploading: FileState?
        public let uploaded: FileState?
        public let error: FileState?
        public let progress: Color?
        public let errorProgress: Color?
        public let progressBackground: Color?
        public let removeButton: Color?
    }

    struct FilePreview: Codable {
        public let text: Text?
        public let errorIcon: Color?
        public let background: Layer?
        public let errorBackground: Layer?
    }

    struct FileState: Codable {
        public let text: Text?
        public let info: Text?
    }

    struct FileErrorState: Codable {
        public let text: Text?
        public let info: Text?
        public let separator: Text?
        public let retry: Text?
    }
}
