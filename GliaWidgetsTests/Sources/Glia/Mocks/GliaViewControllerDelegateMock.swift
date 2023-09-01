@testable import GliaWidgets
import Foundation

final class GliaViewControllerDelegateMock: GliaViewControllerDelegate {
    var invokedEventCall = false
    var invokedEventCallCount = 0
    var invokedEventCallParameter: GliaViewControllerEvent?
    var invokedEventCallParameterList = [GliaViewControllerEvent]()

    func event(_ event: GliaViewControllerEvent) {
        invokedEventCall = true
        invokedEventCallCount += 1
        invokedEventCallParameter = event
        invokedEventCallParameterList.append(event)
    }
}
