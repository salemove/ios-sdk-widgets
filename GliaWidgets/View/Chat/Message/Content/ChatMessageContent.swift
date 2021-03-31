import UIKit

enum ChatMessageContent {
    case text(String)
    case files([LocalFile])
    case choiceOptions([ChatChoiceCardOption])
    case downloads([FileDownload])
}

enum ChatMessageContentAlignment {
    case left
    case right
}
