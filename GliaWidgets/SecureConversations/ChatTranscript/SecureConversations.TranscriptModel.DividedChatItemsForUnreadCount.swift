import Foundation

extension SecureConversations.TranscriptModel {
    static func dividedChatItemsForUnreadCount(
        chatItems: [ChatItem],
        unreadCount: Int,
        divider: ChatItem
    ) -> [ChatItem] {
        var tail: [ChatItem] = []
        var unreadCount = unreadCount
        var head = chatItems
        var dividerIndex: Int?
        while unreadCount > 0 {
            // Remove messages from the end of list.
            // In case list has ended, that means unread count
            // is larger than list size, so we break to prevent
            // infinite loop.
            guard let item = head.popLast() else {
                break
            }
            // Removed items are placed into separate list,
            // to be later combined with initial one.
            tail.insert(item, at: 0)

            // We treat only operator messages
            // eligible to be counted as unread.
            if item.isOperatorMessage {
                // Update divider insertion index with
                // next relevant one.
                dividerIndex = head.endIndex
                unreadCount -= 1
            }
        }

        // At this point we have finished search for insertion
        // index for divider, so we combine two lists together.
        var result = head + tail

        // Make sure that divider index is within safe bounds
        // before performing the insertion.
        if let dividerIndex, dividerIndex <= result.endIndex {
            result.insert(divider, at: dividerIndex)
        }

        return result
    }
}
