import UIKit

enum ChatMessageContent {
    case text(String)
    case downloads([FileDownload<ChatEngagementFile>])
}
