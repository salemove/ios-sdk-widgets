import UIKit

enum ChatMessageContent {
    case text(String)
    case imageDownload(ValueProvider<ChatImageDownloadContentView.State>)
}
