import XCTest
@testable import GliaWidgets

final class AlertViewControllerTests: XCTestCase {
    func test_isSingleActionReplaceable() {
        /// `lhs` is a `AlertKind` which we want to test whether it can be replaced
        /// `rhs` is an array of tuples which contains `AlertKind` to compare with `lhs` and
        /// a `Bool` value is indicating whether lhs `AlertKind` can be replaced with rhs `AlertKind`
        let data: [(lhs: AlertKind, rhs: [(AlertKind, Bool)])] = [
            (.message, [(.message, true),
                        (.singleAction, true),
                        (.singleMediaUpgrade, true),
                        (.screenShareOffer, true),
                        (.confirmation, true)]),
            (.singleAction, [(.message, false),
                             (.singleAction, true),
                             (.singleMediaUpgrade, true),
                             (.screenShareOffer, true),
                             (.confirmation, false)]),
            (.singleMediaUpgrade, [(.message, false),
                                   (.singleAction, true),
                                   (.singleMediaUpgrade, true),
                                   (.screenShareOffer, true),
                                   (.confirmation, false)]),
            (.screenShareOffer, [(.message, false),
                                 (.singleAction, true),
                                 (.singleMediaUpgrade, true),
                                 (.screenShareOffer, true),
                                 (.confirmation, false)]),
            (.confirmation, [(.message, false),
                             (.singleAction, true),
                             (.singleMediaUpgrade, true),
                             (.screenShareOffer, true),
                             (.confirmation, true)])
        ]

        func test(
            replaceable: Replaceable,
            data: (kind: AlertKind, isReplaceable: Bool)
        ) {
            let alert = AlertViewController.mock(type: AlertKind.mock(type: data.kind))
            XCTAssertEqual(replaceable.isReplaceable(with: alert), data.isReplaceable)
        }

        data.forEach { item in
            let alert = AlertViewController.mock(type: AlertKind.mock(type: item.lhs))
            item.rhs.forEach {
                test(replaceable: alert, data: $0)
            }
        }
    }
}
