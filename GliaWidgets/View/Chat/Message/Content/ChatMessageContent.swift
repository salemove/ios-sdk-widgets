import UIKit

enum ChatMessageContent {
    case text(String)
    case files([LocalFile])
    case downloads([FileDownload<ChatEngagementFile>])
    case choiceOptions([ChatChoiceCardOption])
}
