import XCTest
@testable import GliaWidgets

final class OnHoldOverlayVisualEffectViewTests: XCTestCase {

    func test_overlayViewDrawIsExecutedOnMainQueue() {
        enum Call { case mainQueueAsync }
        var calls: [Call] = []
        var gcd = GCD.failing
        gcd.mainQueue.async = { _ in
            calls.append(.mainQueueAsync)
        }
        let environment = OnHoldOverlayVisualEffectView.Environment(gcd: gcd)
        let view = OnHoldOverlayVisualEffectView(environment: environment)

        view.draw(.zero)

        XCTAssertEqual(calls, [.mainQueueAsync])
    }
}
