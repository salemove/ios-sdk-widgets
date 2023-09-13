import Foundation
import XCTest
@testable import GliaWidgets

final class LocalizationTests: XCTestCase {
    let testString = "Glia"

    func test_stringProvider() {
        let stringProviding = StringProviding(getRemoteString: { _ in self.testString })

        let localizationString = Localization.tr(
            "",
            "",
            fallback: "",
            stringProviding: stringProviding
        )

        XCTAssertEqual(localizationString, testString)
    }

    func test_fallback() {
        let localizationString = Localization.tr(
            "",
            "",
            fallback: testString
        )

        XCTAssertEqual(localizationString, testString)
    }

    func test_fallbackWhenStringProvidingReturnsNil() {
        let stringProviding = StringProviding(getRemoteString: { _ in nil })

        let localizationString = Localization.tr(
            "",
            "",
            fallback: testString,
            stringProviding: stringProviding
        )

        XCTAssertEqual(localizationString, testString)
    }

    func test_fileFromString() {
        let localizationString = Localization.tr(
            "Localizable",
            "alert.action.settings",
            fallback: ""
        )

        XCTAssertEqual(localizationString, "Settings")
    }

    func test_fileFromStringWhenStringProvidingReturnsNil() {
        let stringProviding = StringProviding(getRemoteString: { _ in nil })

        let localizationString = Localization.tr(
            "Localizable",
            "alert.action.settings",
            fallback: "",
            stringProviding: stringProviding
        )

        XCTAssertEqual(localizationString, "Settings")
    }
}
