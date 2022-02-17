import Foundation
import UIKit
@testable import GliaWidgets

extension Interactor {

    static func mock() -> Interactor {
        .init(
            with: .mock(),
            queueID: "4CC83BDF-1C04-4B05-87B3-4D558B8F6999",
            visitorContext: .mock(),
            environment: .init(coreSdk: .failing)
        )
    }
}

extension AlertConfiguration {

    static func mock(showsPoweredBy: Bool = true) -> Self {
        .init(
            leaveQueue: .init(showsPoweredBy: showsPoweredBy),
            endEngagement: .init(showsPoweredBy: showsPoweredBy),
            operatorEndedEngagement: .mock(),
            operatorsUnavailable: .mock(),
            mediaUpgrade: .mock(),
            audioUpgrade: .mock(),
            oneWayVideoUpgrade: .mock(),
            twoWayVideoUpgrade: .mock(),
            screenShareOffer: .mock(),
            endScreenShare: .mock(),
            microphoneSettings: .mock(),
            cameraSettings: .mock(),
            mediaSourceNotAvailable: .mock(),
            unexpectedError: .mock(),
            apiError: .mock()
        )
    }
}

extension SingleActionAlertConfiguration {

    static func mock(
        title: String? = "mocked-title",
        message: String? = "mocked-message",
        buttonTitle: String? = "mocked-button-title"
    ) -> Self {
        .init(
            title: title,
            message: message,
            buttonTitle: buttonTitle
        )
    }
}

extension ScreenShareOfferAlertConfiguration {
    static func mock() -> Self {
        .init(
            title: "mocked-title",
            message: "mocked-message",
            titleImage: nil,
            decline: "mocked-decline",
            accept: "mocked-accept",
            showsPoweredBy: true
        )
    }
}

extension ConfirmationAlertConfiguration {
    static func mock() -> Self {
        .init(showsPoweredBy: true)
    }
}

extension SingleMediaUpgradeAlertConfiguration {

    static func mock() -> Self {
        .init(
            title: "mocked-title",
            titleImage: nil,
            decline: "mocked-decline",
            accept: "mocked-accept",
            showsPoweredBy: true
        )
    }
}

extension MessageAlertConfiguration {

    static func mock(
        title: String? = "mocked-title",
        message: String? = "mocked-message"
    ) -> Self {
        .init(
            title: title,
            message: message
        )
    }
}

extension MediaUpgradeActionStyle {

    static func mock() -> Self {
        .init(
            title: "",
            titleFont: .systemFont(ofSize: 9),
            titleColor: .white,
            info: "",
            infoFont: .systemFont(ofSize: 9),
            infoColor: .white,
            borderColor: .white,
            backgroundColor: .white,
            icon: UIImage(),
            iconColor: .white
        )
    }
}

extension MultipleMediaUpgradeAlertConfiguration {

    static func mock(
        title: String = "mocked-title",
        audioUpgradeAction: MediaUpgradeActionStyle = .mock(),
        phoneUpgradeAction: MediaUpgradeActionStyle = .mock(),
        showsPoweredBy: Bool = true
    ) -> Self {
        .init(
            title: title,
            audioUpgradeAction: audioUpgradeAction,
            phoneUpgradeAction: phoneUpgradeAction,
            showsPoweredBy: showsPoweredBy
        )
    }
}

extension SettingsAlertConfiguration {

    static func mock() -> Self {
        .init(
            title: "mocked-title",
            message: "mocked-message",
            settingsTitle: "mocked-settings-title",
            cancelTitle: "mocked-cancel-title"
        )
    }
}
