@testable import GliaWidgets
import WebKit
import XCTest

final class WebMessageCardViewTests: XCTestCase {
    private var window: UIWindow!
    private var delegate: DelegateMock!

    /// WebKit runs out of process and its first page load on a cold simulator can take
    /// several seconds on a slow CI runner. Loading one page here keeps that cost out of
    /// every test's own timeout.
    override static func setUp() {
        super.setUp()
        let warmedUp = XCTestExpectation(description: "WebKit warmed up")
        let delegate = DelegateMock()
        delegate.onMobileAction = { action in
            if action == "warm-up" { warmedUp.fulfill() }
        }
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let view = WebMessageCardView(
            policyProvider: .customResponseCard,
            message: .init(chatMessage: .mock()),
            metadata: .init(html: "<html><body><script>window.onload = function () { callMobileAction('warm-up'); };</script></body></html>")
        )
        view.delegate = delegate
        view.frame = window.bounds
        window.addSubview(view)
        view.startLoading()
        _ = XCTWaiter.wait(for: [warmedUp], timeout: 60)
        withExtendedLifetime((window, delegate)) {}
    }

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

    func test_scriptClickOnLinkIsCancelled() {
        assertScriptClickIsCancelled(
            body: #"<a id="link" href="https://mock.mock">link</a>"#,
            click: "document.getElementById('link').click();"
        )
    }

    func test_dispatchedClickOnLinkIsCancelled() {
        assertScriptClickIsCancelled(
            body: #"<a id="link" href="https://mock.mock">link</a>"#,
            click: "document.getElementById('link').dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));"
        )
    }

    func test_scriptClickOnElementInsideLinkIsCancelled() {
        assertScriptClickIsCancelled(
            body: #"<a href="https://mock.mock"><span id="inner">link</span></a>"#,
            click: "document.getElementById('inner').click();"
        )
    }

    func test_scriptClickOnBlankTargetLinkIsCancelled() {
        assertScriptClickIsCancelled(
            body: #"<a id="link" target="_blank" href="https://mock.mock">link</a>"#,
            click: "document.getElementById('link').click();"
        )
    }

    func test_scriptClickOnLinkWithPatchedPreventDefaultIsCancelled() {
        assertScriptClickIsCancelled(
            body: #"<a id="link" href="https://mock.mock">link</a>"#,
            click: """
                Event.prototype.preventDefault = function () {};
                document.getElementById('link').click();
            """
        )
    }

    func test_scriptLocationChangeDoesNotSelectURL() {
        assertNavigationDoesNotSelectURL(
            body: "",
            onLoad: "location.href = 'https://mock.mock';"
        )
    }

    func test_iframeDoesNotSelectURL() {
        assertNavigationDoesNotSelectURL(
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

        wait(for: [mobileActionCalled], timeout: Self.webViewTimeout)
    }
}

private extension WebMessageCardViewTests {
    /// WebKit runs out of process, so the first page load on a cold simulator can take several seconds.
    /// Every wait below ends as soon as its expectation is fulfilled, so a generous timeout costs nothing.
    static let webViewTimeout: TimeInterval = 10
    static let mockHost = "mock.mock"
    static let defaultPreventedAction = "defaultPrevented:"

    /// The link click guard runs on `window` in the capture phase, so a page listener
    /// on `document` observes `defaultPrevented` after the guard has made its decision.
    func assertScriptClickIsCancelled(
        body: String,
        click: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let clickObserved = expectation(description: "Click observed by page script")
        delegate.onMobileAction = { action in
            guard action.hasPrefix(Self.defaultPreventedAction) else { return }
            XCTAssertEqual(action, Self.defaultPreventedAction + "true", file: file, line: line)
            clickObserved.fulfill()
        }
        delegate.onSelectURL = { url in
            XCTFail("Unexpected URL selection: \(url)", file: file, line: line)
        }

        startLoading(html: """
            <html><body>
            \(body)
            <script>
                window.onload = function () {
                    document.addEventListener('click', function (event) {
                        callMobileAction('\(Self.defaultPreventedAction)' + event.defaultPrevented);
                    }, true);
                    \(click)
                };
            </script>
            </body></html>
        """)

        wait(for: [clickObserved], timeout: Self.webViewTimeout)
    }

    /// Navigations that are not clicks bypass the guard and reach the navigation policy,
    /// so the policy decision for the mock host is the signal that the card handled them.
    func assertNavigationDoesNotSelectURL(
        body: String,
        onLoad: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let policyDecided = expectation(description: "Navigation policy decided for mock host")
        let policyProvider = WKNavigationPolicyProvider { request in
            let result = WKNavigationPolicyProvider.customResponseCard.policy(request)
            guard request.url.host == Self.mockHost else { return result }
            XCTAssertEqual(result.policy, .cancel, file: file, line: line)
            XCTAssertFalse(result.shouldHandleUrlSelection, file: file, line: line)
            policyDecided.fulfill()
            return result
        }
        delegate.onSelectURL = { url in
            XCTFail("Unexpected URL selection: \(url)", file: file, line: line)
        }

        startLoading(
            html: """
                <html><body>
                \(body)
                <script>window.onload = function () { \(onLoad) };</script>
                </body></html>
            """,
            policyProvider: policyProvider
        )

        wait(for: [policyDecided], timeout: Self.webViewTimeout)
    }

    func startLoading(
        html: String,
        policyProvider: WKNavigationPolicyProvider = .customResponseCard
    ) {
        let view = WebMessageCardView(
            policyProvider: policyProvider,
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
