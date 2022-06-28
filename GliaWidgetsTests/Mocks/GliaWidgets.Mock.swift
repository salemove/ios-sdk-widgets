import Foundation
import UIKit
@testable import GliaWidgets

extension Interactor {

    static func mock() throws -> Interactor {
        .init(
            with: try .mock(),
            queueID: "4CC83BDF-1C04-4B05-87B3-4D558B8F6999",
            visitorContext: .mock(),
            environment: .init(
                coreSdk: .failing,
                gcd: .mock
            )
        )
    }
}
