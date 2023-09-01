import Foundation
import XCTest
@testable import GliaWidgets

final class StringTemplateTests: XCTestCase {
    func test_operatorWithTemplate() {
        let operatorName = "Glia"
        let string = "Operator: {operatorName}"

        let compatibilityLayerResult = Localization.operatorName(operatorName, on: string)
        XCTAssertEqual(compatibilityLayerResult, "Operator: Glia")

        let templateResult = string.withOperatorName(operatorName)
        XCTAssertEqual(compatibilityLayerResult, templateResult)
    }

    func test_operatorWithoutTemplate() {
        let operatorName = Localization.operatorName("Glia", on: nil)

        XCTAssertEqual(operatorName, "Glia")
    }
}
