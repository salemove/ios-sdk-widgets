@testable import GliaWidgets
import XCTest

final class WebMessageCardViewTests: XCTestCase {
    private var window: UIWindow!
    private var delegate: DelegateMock!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        delegate = DelegateMock()
    }

    override func tearDown() {
        window = nil
        delegate = nil
        super.tearDown()
    }

    func test_scriptClickOnLinkDoesNotSelectURL() {
        assertNoURLSelected(
            body: #"<a id="link" href="https://mock.mock">link</a>"#,
            onLoad: "document.getElementById('link').click();"
        )
    }

    func test_dispatchedClickOnLinkDoesNotSelectURL() {
        assertNoURLSelected(
            body: #"<a id="link" href="https://mock.mock">link</a>"#,
            onLoad: "document.getElementById('link').dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));"
        )
    }

    func test_scriptClickOnElementInsideLinkDoesNotSelectURL() {
        assertNoURLSelected(
            body: #"<a href="https://mock.mock"><span id="inner">link</span></a>"#,
            onLoad: "document.getElementById('inner').click();"
        )
    }

    func test_scriptClickOnBlankTargetLinkDoesNotSelectURL() {
        assertNoURLSelected(
            body: #"<a id="link" target="_blank" href="https://mock.mock">link</a>"#,
            onLoad: "document.getElementById('link').click();"
        )
    }

    func test_scriptClickOnLinkWithPatchedPreventDefaultDoesNotSelectURL() {
        assertNoURLSelected(
            body: #"<a id="link" href="https://mock.mock">link</a>"#,
            onLoad: """
                Event.prototype.preventDefault = function () {};
                document.getElementById('link').click();
            """
        )
    }

    func test_scriptLocationChangeDoesNotSelectURL() {
        assertNoURLSelected(
            body: "",
            onLoad: "location.href = 'https://mock.mock';"
        )
    }

    func test_iframeDoesNotSelectURL() {
        assertNoURLSelected(
            body: #"<iframe src="https://mock.mock"></iframe>"#,
            onLoad: ""
        )
    }

    func test_scriptClickOnMobileActionButtonCallsMobileAction() {
        let mobileActionCalled = expectation(description: "Mobile action called")
        delegate.onMobileAction = { action in
            XCTAssertEqual(action, "mock-action")
            mobileActionCalled.fulfill()
        }

        startLoading(html: """
            <html><body>
            <button id="button" onclick="callMobileAction('mock-action')">button</button>
            <script>window.onload = function () { document.getElementById('button').click(); };</script>
            </body></html>
        """)

        wait(for: [mobileActionCalled], timeout: 3)
    }
}

private extension WebMessageCardViewTests {
    static let loadedAction = "mock-loaded"

    /// `onLoad` runs after the card's bridge scripts are injected, then signals a mobile action,
    /// so the test knows the card script ran before checking that no URL was selected.
    func assertNoURLSelected(
        body: String,
        onLoad: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let cardScriptRan = expectation(description: "Card script ran")
        let urlSelected = expectation(description: "URL selected")
        urlSelected.isInverted = true
        delegate.onMobileAction = { action in
            if action == Self.loadedAction { cardScriptRan.fulfill() }
        }
        delegate.onSelectURL = { url in
            XCTFail("Unexpected URL selection: \(url)", file: file, line: line)
            urlSelected.fulfill()
        }

        startLoading(html: """
            <html><body>
            \(body)
            <script>
                window.onload = function () {
                    \(onLoad)
                    callMobileAction('\(Self.loadedAction)');
                };
            </script>
            </body></html>
        """)

        wait(for: [cardScriptRan, urlSelected], timeout: 3)
    }

    func startLoading(html: String) {
        let view = WebMessageCardView(
            policyProvider: .customResponseCard,
            message: .init(chatMessage: .mock()),
            metadata: .init(html: html)
        )
        view.delegate = delegate
        view.frame = window.bounds
        window.addSubview(view)
        view.startLoading()
    }
}

private final class DelegateMock: WebMessageCardViewDelegate {
    var onMobileAction: (String) -> Void = { _ in }
    var onSelectURL: (URL) -> Void = { _ in }

    func viewDidUpdateHeight(
        _ view: WebMessageCardView,
        height: CGFloat,
        for messageId: MessageRenderer.Message.Identifier
    ) {}

    func didSelectCustomCardOption(
        _ view: WebMessageCardView,
        selectedOption: HtmlMetadata.Option,
        for messageId: MessageRenderer.Message.Identifier
    ) {}

    func didCallMobileAction(_ view: WebMessageCardView, action: String) {
        onMobileAction(action)
    }

    func didSelectURL(_ view: WebMessageCardView, url: URL) {
        onSelectURL(url)
    }
}
