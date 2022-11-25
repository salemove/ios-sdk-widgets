import Foundation

extension RemoteConfiguration {
    struct Chat: Codable {
        let background: Layer?
        let header: Header?
        let connect: EngagementStates?
        let operatorMessage: MessageBalloon?
        let visitorMessage: MessageBalloon?
        let input: Input?
        let responseCard: ResponseCard?
        let audioUpgrade: Upgrade?
        let videoUpgrade: Upgrade?
        let bubble: Bubble?
        let attachmentSourceList: AttachmentSourceList?
        let unreadIndicator: Bubble?
        let typingIndicator: Color?
    }

    struct Header: Codable {
        let background: Layer?
        let text: Text?
        let backButton: Button?
        let closeButton: Button?
        let endButton: Button?
        let endScreenSharingButton: Button?
    }

    struct MessageBalloon: Codable {
        let background: Layer?
        let text: Text?
        let file: FileMessage?
        let status: Text?
        let userImage: UserImageStyle?
    }

    struct FileMessage: Codable {
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

    struct EngagementStates: Codable {
        let `operator`: Operator?
        let queue: EngagementState?
        let connecting: EngagementState?
        let connected: EngagementState?
        let transferring: EngagementState?
        let onHold: EngagementState?
    }

    struct EngagementState: Codable {
        let title: Text?
        let description: Text?
    }

    struct Operator: Codable {
        let image: UserImageStyle?
        let animationColor: Color?
        let overlayColor: Color?
    }

    struct Input: Codable {
        let text: Text?
        let placeholder: Text?
        let separator: Color?
        let sendButton: Button?
        let mediaButton: Button?
        let background: Layer?
        let fileUploadBar: FileUploadBar?
    }

    struct ResponseCard: Codable {
        let background: Layer?
        let option: ResponseCardOption?
        let text: Text?
        let userImage: UserImageStyle?
    }

    struct ResponseCardOption: Codable {
        let normal: Button?
        let selected: Button?
        let disabled: Button?
    }

    struct Upgrade: Codable {
        let text: Text?
        let description: Text?
        let iconColor: Color?
        let background: Layer?
    }

    struct AttachmentSourceList: Codable {
        let items: [AttachmentSource]?
        let separator: Color?
        let background: Color?
    }

    struct AttachmentSource: Codable {
        let type: AttachmentSourceType
        let text: Text?
        let tintColor: Color?
    }

    enum AttachmentSourceType: String, Codable {
        case photoLibrary, takePhoto, browse
    }

    struct FileUploadBar: Codable {
        let filePreview: FilePreview?
        let uploading: FileState?
        let uploaded: FileState?
        let error: FileState?
        let progress: Color?
        let errorProgress: Color?
        let progressBackground: Color?
        let removeButton: Color?
    }

    struct FilePreview: Codable {
        let text: Text?
        let errorIcon: Color?
        let background: Layer?
        let errorBackground: Layer?
    }

    struct FileState: Codable {
        let text: Text?
        let info: Text?
    }

    struct FileErrorState: Codable {
        let text: Text?
        let info: Text?
        let separator: Text?
        let retry: Text?
    }
}
