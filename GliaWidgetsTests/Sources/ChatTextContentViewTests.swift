import XCTest

@testable import GliaWidgets

class ChatTextContentViewTests: XCTestCase {
    var view: ChatTextContentView!

    func test_handleUrlWithPhoneOpensURLWithUIApplication() throws {
        enum Call: Equatable { case openUrl(URL) }

        var calls: [Call] = []
        var environment = ChatTextContentView.Environment(
            uiApplication: .failing
        )

        environment.uiApplication.canOpenURL = { _ in true }
        environment.uiApplication.open = {
            calls.append(.openUrl($0))
        }

        view = .mock(environment: environment)

        let telUrl = URL(string: "tel:12345678")!
        view.handleUrl(url: telUrl)

        XCTAssertEqual(calls, [.openUrl(telUrl)])
    }
    
    func test_handleUrlWithEmailOpensURLWithUIApplication() throws {
        enum Call: Equatable { case openUrl(URL) }

        var calls: [Call] = []
        var environment = ChatTextContentView.Environment(
            uiApplication: .failing
        )

        environment.uiApplication.canOpenURL = { _ in true }
        environment.uiApplication.open = {
            calls.append(.openUrl($0))
        }

        view = .mock(environment: environment)

        let mailUrl = URL(string: "mailto:mock@mock.mock")!
        view.handleUrl(url: mailUrl)

        XCTAssertEqual(calls, [.openUrl(mailUrl)])
    }
    
    func test_handleUrlWithLinkOpensCalsLinkTapped() throws {
        enum Call: Equatable { case linkTapped(URL) }
        var calls: [Call] = []

        let environment = ChatTextContentView.Environment(
            uiApplication: .failing
        )

        view = .mock(environment: environment)
        view.linkTapped = {
            calls.append(.linkTapped($0))
        }

        let linkUrl = URL(string: "https://mock.mock")!
        view.handleUrl(url: linkUrl)

        XCTAssertEqual(calls, [.linkTapped(linkUrl)])
    }
}
