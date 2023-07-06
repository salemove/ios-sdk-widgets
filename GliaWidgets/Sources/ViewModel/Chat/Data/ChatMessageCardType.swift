import Foundation

enum ChatMessageCardType: Equatable {
    case choiceCard
    case customCard
    case gvaPersistenButton(GvaButton)
    case gvaResponseText(GvaResponseText)
    case gvaQuickReply(GvaButton)
    case gvaGallery(GvaGallery)
    case none
}
