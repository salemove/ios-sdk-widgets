import Foundation

extension SecureConversations {
    enum ShouldShowLeaveCurrentConversationSource {
        /// Used when `shouldShowLeaveSecureConversationDialog` is called once Chat Transcript screen is opened
        case transcriptOpened
        /// Used when `shouldShowLeaveSecureConversationDialog` is called once a visitor selects media type from
        /// `Need Live Support?` banner.
        case entryWidgetTopBanner
    }
}
