@testable import GliaWidgets
import XCTest

final class ChatMessageEntryViewTests: XCTestCase {
    var messagageEntryView: ChatMessageEntryView!

    override func setUp() {
        super.setUp()
        messagageEntryView = ChatMessageEntryView.mock()
    }

    override func tearDown() {
        messagageEntryView = nil
        super.tearDown()
    }

    func test_text_view_height_with_more_than_max_lines() {
        let exampleText = "This\nis a\nfive\nlines\ntext"
        let maxTextLines = CGFloat(messagageEntryView.maxTextLines)
        let oneLineHeight = Theme().chatStyle.messageEntry.messageFont.lineHeight
        let expectedTextViewHeight = oneLineHeight * maxTextLines

        messagageEntryView.messageText = exampleText
        messagageEntryView.defineLayout()
        let textActualHeight = messagageEntryView.textViewHeightConstraint?.constant

        XCTAssertEqual(textActualHeight ?? 0.0, expectedTextViewHeight)
    }

    func test_text_view_is_scrollable() {
        messagageEntryView.defineLayout()
        XCTAssertEqual(messagageEntryView.textView.isScrollEnabled, false)
        let exampleText = "This\nis a\nfive\nlines\ntext"

        messagageEntryView.messageText = exampleText
        messagageEntryView.defineLayout()

        XCTAssertEqual(messagageEntryView.textView.isScrollEnabled, true)
    }
}
