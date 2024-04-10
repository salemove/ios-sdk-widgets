@testable import GliaWidgets
import XCTest

final class GliaPresenterTests: XCTestCase {
    func test_presentViewControllerLogsWarningAboutBubbleViewController() {
        var results: [Bool] = []
        let viewController = UIViewController()
        let gliaPresenter = GliaPresenter(
            environment: .failing.transform {
                $0.appWindowsProvider.windows = { [BubbleWindow.mock(makeKeyAndVisible: true)] }
                $0.log.warningClosure = { message, _, _, _ in
                    results.append("\(message)".hasSuffix(
                        """
                        Attempt to present \(type(of: viewController)) on \(BubbleViewController.self).
                        """
                    ))
                }
            }
        )
        gliaPresenter.present(viewController, animated: true)
        XCTAssertEqual(results, [true])
    }

    func test_windowReturnsNonBubbleWindowKeyWindow() {
        let bubbleWindow = BubbleWindow.mock(makeKeyAndVisible: true)
        let nonBubbleWindow = UIWindow.mock(rootViewController: .init())
        nonBubbleWindow.makeKeyAndVisible()
        let gliaPresenter = GliaPresenter(
            environment: .failing.transform {
                $0.appWindowsProvider.windows = { [bubbleWindow, nonBubbleWindow] }
            }
        )
        XCTAssertEqual(nonBubbleWindow, gliaPresenter.window)
    }

    func test_windowReturnsNonBubbleWindowWithRootViewController() {
        let bubbleWindow = BubbleWindow.mock(makeKeyAndVisible: true)
        let nonBubbleWindow = UIWindow.mock(rootViewController: .init())
        let gliaPresenter = GliaPresenter(
            environment: .failing.transform {
                $0.appWindowsProvider.windows = { [bubbleWindow, nonBubbleWindow] }
            }
        )
        XCTAssertEqual(nonBubbleWindow, gliaPresenter.window)
    }

    func test_windowReturnsBubbleWindow() {
        let bubbleWindow = BubbleWindow.mock(makeKeyAndVisible: true)
        let nonBubbleWindow = UIWindow()
        let gliaPresenter = GliaPresenter(
            environment: .failing.transform {
                $0.appWindowsProvider.windows = { [bubbleWindow, nonBubbleWindow] }
            }
        )
        XCTAssertEqual(bubbleWindow, gliaPresenter.window)
    }

    func test_windowReturnsNonKeyBubbleWindow() {
        let bubbleWindow = BubbleWindow.mock(makeKeyAndVisible: false)
        let nonBubbleWindow = UIWindow()
        let gliaPresenter = GliaPresenter(
            environment: .failing.transform {
                $0.appWindowsProvider.windows = { [bubbleWindow, nonBubbleWindow] }
            }
        )
        XCTAssertEqual(bubbleWindow, gliaPresenter.window)
    }
}

extension BubbleWindow.Environment {
    static let mock = Self(uiScreen: .mock, uiApplication: .mock)
    static let failing = Self(uiScreen: .failing, uiApplication: .failing)
}
