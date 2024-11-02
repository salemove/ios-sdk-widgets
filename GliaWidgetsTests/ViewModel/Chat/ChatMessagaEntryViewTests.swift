@testable import GliaWidgets
import XCTest

final class ChatMessageEntryViewTests: XCTestCase {
    var messageEntryView: ChatMessageEntryView!

    override func setUp() {
        super.setUp()
        messageEntryView = ChatMessageEntryView.mock()
    }

    override func tearDown() {
        messageEntryView = nil
        super.tearDown()
    }

    func test_text_view_height_with_more_than_max_lines() {
        let exampleText = "This\nis a\nfive\nlines\ntext"
        let maxTextLines = CGFloat(messageEntryView.maxTextLines)
        let oneLineHeight = Theme().chatStyle.messageEntry.enabled.messageFont.lineHeight
        let expectedTextViewHeight = oneLineHeight * maxTextLines

        messageEntryView.messageText = exampleText
        messageEntryView.defineLayout()
        let textActualHeight = messageEntryView.textViewHeightConstraint?.constant

        XCTAssertEqual(textActualHeight ?? 0.0, expectedTextViewHeight)
    }

    func test_text_view_is_scrollable() {
        messageEntryView.defineLayout()
        XCTAssertEqual(messageEntryView.textView.isScrollEnabled, false)
        let exampleText = "This\nis a\nfive\nlines\ntext"

        messageEntryView.messageText = exampleText
        messageEntryView.defineLayout()

        XCTAssertEqual(messageEntryView.textView.isScrollEnabled, true)
    }
}
