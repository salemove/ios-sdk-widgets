#if DEBUG
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
            apiError: .mock(),
            unavailableMessageCenter: .mock(),
            unavailableMessageCenterForBeingUnauthenticated: .mock(),
            unsupportedGvaBroadcastError: .mock(),
            liveObservationConfirmation: .mock(),
            expiredAccessTokenError: .mock()
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

    static func liveObservationMock() -> Self {
        .init(
            title: "Live Observation Confirmation",
            message: "This is mock message",
            negativeTitle: "Cancel",
            positiveTitle: "Allow",
            showsPoweredBy: true
        )
    }

    static func liveObservationWithLinksMock() -> Self {
        .init(
            title: "Live Observation Confirmation",
            message: "This is mock message",
            firstLinkButtonUrl: "https://www.google.com",
            secondLinkButtonUrl: "https://www.google.ee",
            negativeTitle: "Cancel",
            positiveTitle: "Allow",
            showsPoweredBy: true
        )
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
            icon: .init(),
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
#endif
