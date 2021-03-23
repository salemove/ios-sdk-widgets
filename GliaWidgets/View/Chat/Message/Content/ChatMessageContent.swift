import UIKit

enum ChatMessageContent {
    case text(String)
    case files([LocalFile])
    case downloads([FileDownload])
}

enum ChatMessageContentAlignment {
    case left
    case right
}
