@testable import GliaWidgets
import UIKit
import XCTest

final class AlertTypeComposerTests: XCTestCase {
    var composer: AlertManager.AlertTypeComposer!

    override func setUp() {
        super.setUp()

        composer = .init(
            environment: .create(with: .mock()),
            theme: .mock()
        )
    }

    func testComposeAlertWithAudioMediaUpgradeInput() throws {
        let operatorName = "Mock"
        let offer = try CoreSdkClient.MediaUpgradeOffer(type: .audio, direction: .twoWay)
        let input: AlertInputType = .mediaUpgrade(
            operators: operatorName,
            offer: offer,
            accepted: nil,
            declined: nil,
            answer: { _, _ in }
        )
        let alertType = try composer.composeAlert(input: input)

        switch alertType {
        case let .singleMediaUpgrade(configuration, _, _, _):
            let expected = Theme().alertConfiguration.audioUpgrade.withOperatorName(operatorName)
            XCTAssertEqual(configuration, expected)
        default:
            XCTFail("alertType should be singleMediaUpgrade")
        }
    }

    func testComposeAlertWithOneWayVideoMediaUpgradeInput() throws {
        let operatorName = "Mock"
        let offer = try CoreSdkClient.MediaUpgradeOffer(type: .video, direction: .oneWay)
        let input: AlertInputType = .mediaUpgrade(
            operators: operatorName,
            offer: offer,
            accepted: nil,
            declined: nil,
            answer: { _, _ in }
        )
        let alertType = try composer.composeAlert(input: input)

        switch alertType {
        case let .singleMediaUpgrade(configuration, _, _, _):
            let expected = Theme().alertConfiguration.oneWayVideoUpgrade.withOperatorName(operatorName)
            XCTAssertEqual(configuration, expected)
        default:
            XCTFail("alertType should be singleMediaUpgrade")
        }
    }

    func testComposeAlertWithTwoWayVideoMediaUpgradeInput() throws {
        let operatorName = "Mock"
        let offer = try CoreSdkClient.MediaUpgradeOffer(type: .video, direction: .twoWay)
        let input: AlertInputType = .mediaUpgrade(
            operators: operatorName,
            offer: offer,
            accepted: nil,
            declined: nil,
            answer: { _, _ in }
        )
        let alertType = try composer.composeAlert(input: input)

        switch alertType {
        case let .singleMediaUpgrade(configuration, _, _, _):
            let expected = Theme().alertConfiguration.twoWayVideoUpgrade.withOperatorName(operatorName)
            XCTAssertEqual(configuration, expected)
        default:
            XCTFail("alertType should be singleMediaUpgrade")
        }
    }
}
