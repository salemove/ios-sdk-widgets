@testable import GliaWidgets
import XCTest

final class SecureConversationsTranscriptModelTests: XCTestCase {
    // Since ChatItem does not conform to Equatable,
    // one of the ways to evaluate if it is the exact
    // item is by doing identity check.
    // We declare items to be checked here in order to
    // reuse them for different cases.
    let divider = ChatItem(kind: .unreadMessageDivider)
    let operatorMessage = ChatItem(kind: .operatorMessage(.mock(), showsImage: false, imageUrl: nil))
    let visitorMessage = ChatItem(kind: .visitorMessage(.mock(), status: ""))

    func testDividerTakesIntoAccountOnlyOperatorMessages() {
        let unreadCount = 1

        let messageItems: [ChatItem] = [
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         visitorMessage,
         operatorMessage,
         visitorMessage,
        ]

        let expected = [
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            visitorMessage,
            divider,
            operatorMessage,
            visitorMessage,
        ]

        let result = SecureConversations.TranscriptModel.dividedChatItemsForUnreadCount(
            chatItems: messageItems,
            unreadCount: unreadCount,
            divider: divider
        )

        XCTAssertEqual(result.map(describe), expected.map(describe))
    }

    func testDividerIsPlacedAtStart() {
        let unreadCount = 6

        let messageItems: [ChatItem] = [
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         visitorMessage,
         visitorMessage,
         operatorMessage
        ]

        let expected = [
            divider,
            operatorMessage,
            operatorMessage,
            operatorMessage,
            operatorMessage,
            operatorMessage,
            visitorMessage,
            visitorMessage,
            operatorMessage,
        ]

        let result = SecureConversations.TranscriptModel.dividedChatItemsForUnreadCount(
            chatItems: messageItems,
            unreadCount: unreadCount,
            divider: divider
        )

        XCTAssertEqual(result.map(describe), expected.map(describe))
    }

    func testDividerIsPlacedInTheMiddle() {
        let unreadCount = 3
        let messageItems: [ChatItem] = [
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         visitorMessage,
         visitorMessage,
         operatorMessage
        ]

        let expected = [
            operatorMessage,
            operatorMessage,
            operatorMessage,
            divider,
            operatorMessage,
            operatorMessage,
            visitorMessage,
            visitorMessage,
            operatorMessage
        ]

        let result = SecureConversations.TranscriptModel.dividedChatItemsForUnreadCount(
            chatItems: messageItems,
            unreadCount: unreadCount,
            divider: divider
        )

        XCTAssertEqual(result.map(describe), expected.map(describe))
    }

    func testDividerRespectsMessageListSize() {
        let unreadCount = Int.max
        let messageItems: [ChatItem] = [
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         visitorMessage,
         visitorMessage,
         operatorMessage
        ]

        let expected = [
            divider,
            operatorMessage,
            operatorMessage,
            operatorMessage,
            operatorMessage,
            operatorMessage,
            visitorMessage,
            visitorMessage,
            operatorMessage
        ]

        let result = SecureConversations.TranscriptModel.dividedChatItemsForUnreadCount(
            chatItems: messageItems,
            unreadCount: unreadCount,
            divider: divider
        )

        XCTAssertEqual(result.map(describe), expected.map(describe))
    }

    func testDividerIsNotAddedForZeroUnreadCount() {
        let unreadCount = 0
        let messageItems: [ChatItem] = [
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         visitorMessage,
         visitorMessage,
         operatorMessage
        ]

        let expected = messageItems

        let result = SecureConversations.TranscriptModel.dividedChatItemsForUnreadCount(
            chatItems: messageItems,
            unreadCount: unreadCount,
            divider: divider
        )

        XCTAssertEqual(result.map(describe), expected.map(describe))
    }

    func testDividerIsNotAddedForNegativeUnreadCount() {
        let unreadCount = Int.min
        let messageItems: [ChatItem] = [
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         operatorMessage,
         visitorMessage,
         visitorMessage,
         operatorMessage
        ]

        let expected = messageItems

        let result = SecureConversations.TranscriptModel.dividedChatItemsForUnreadCount(
            chatItems: messageItems,
            unreadCount: unreadCount,
            divider: divider
        )

        XCTAssertEqual(result.map(describe), expected.map(describe))
    }

    /// Returns simplified representation of ChatItem to ease
    /// its comparison in tests, specifically in equality assertions, where
    /// o - operator message, v - visitor message, --- - divider.
    func describe(_ item: ChatItem) -> String {
        if item === operatorMessage {
            return "o"
        } else if item === visitorMessage {
            return "v"
        } else if item === divider {
            return "---"
        } else {
            return ""
        }
    }
}
