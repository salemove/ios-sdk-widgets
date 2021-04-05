import UIKit

enum ChatMessageContent {
    case text(String)
    case files([LocalFile])
    case downloads([FileDownload])
    case choiceCard(ChoiceCard)
}

enum ChatMessageContentAlignment {
    case left
    case right
}
