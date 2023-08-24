extension Theme {
    var alertConfigurationStyle: AlertConfiguration {
        let leaveQueue = ConfirmationAlertConfiguration(
            title: Localization.Engagement.QueueLeave.header,
            message: Localization.Engagement.QueueLeave.message,
            negativeTitle: Localization.General.no,
            positiveTitle: Localization.General.yes,
            switchButtonBackgroundColors: true,
            showsPoweredBy: false
        )
        let endEngagement = ConfirmationAlertConfiguration(
            title: Localization.Engagement.End.Confirmation.header,
            message: Localization.Engagement.End.message,
            negativeTitle: Localization.General.no,
            positiveTitle: Localization.General.yes,
            switchButtonBackgroundColors: true,
            showsPoweredBy: true
        )
        let operatorEndedEngagement = SingleActionAlertConfiguration(
            title: Localization.Engagement.Ended.header,
            message: Localization.Engagement.Ended.message,
            buttonTitle: Localization.General.ok
        )
        let endScreenShare = ConfirmationAlertConfiguration(
            title: Localization.Engagement.Alert.ScreenSharing.Stop.header,
            message: Localization.Engagement.Alert.ScreenSharing.Stop.message,
            negativeTitle: Localization.General.no,
            positiveTitle: Localization.General.yes,
            switchButtonBackgroundColors: true,
            showsPoweredBy: showsPoweredBy
        )
        let operatorsUnavailable = MessageAlertConfiguration(
            title: Localization.Engagement.QueueClosed.header,
            message: Localization.Engagement.QueueClosed.message
        )
        let audioAction = MediaUpgradeActionStyle(
            title: Localization.Media.Audio.name,
            titleFont: font.header3,
            titleColor: color.baseDark,
            info: Localization.Engagement.MediaUpgrade.Audio.info,
            infoFont: font.subtitle,
            infoColor: color.baseDark,
            borderColor: color.primary,
            backgroundColor: color.background,
            icon: Asset.upgradeAudio.image,
            iconColor: color.primary
        )
        let phoneAction = MediaUpgradeActionStyle(
            title: Localization.Media.Phone.name,
            titleFont: font.header3,
            titleColor: color.baseDark,
            info: Localization.Engagement.MediaUpgrade.Phone.info,
            infoFont: font.subtitle,
            infoColor: color.baseDark,
            borderColor: color.primary,
            backgroundColor: color.background,
            icon: Asset.upgradePhone.image,
            iconColor: color.primary
        )
        let mediaUpgrade = MultipleMediaUpgradeAlertConfiguration(
            title: Localization.Engagement.offerUpgrade,
            audioUpgradeAction: audioAction,
            phoneUpgradeAction: phoneAction,
            showsPoweredBy: showsPoweredBy
        )
        let audioUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Localization.Upgrade.Audio.title,
            titleImage: Asset.upgradeAudio.image,
            decline: Localization.General.decline,
            accept: Localization.General.accept,
            showsPoweredBy: showsPoweredBy
        )
        let oneWayVideoUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Localization.Upgrade.Video.OneWay.title,
            titleImage: Asset.upgradeVideo.image,
            decline: Localization.General.decline,
            accept: Localization.General.accept,
            showsPoweredBy: showsPoweredBy
        )
        let twoWayVideoUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Localization.Upgrade.Video.TwoWay.title,
            titleImage: Asset.upgradeVideo.image,
            decline: Localization.General.decline,
            accept: Localization.General.accept,
            showsPoweredBy: showsPoweredBy
        )
        let screenShareOffer = ScreenShareOfferAlertConfiguration(
            title: Localization.Engagement.Alert.ScreenSharing.Start.header,
            message: Localization.Engagement.Alert.ScreenSharing.Start.message,
            titleImage: Asset.startScreenShare.image,
            decline: Localization.General.decline,
            accept: Localization.General.accept,
            showsPoweredBy: showsPoweredBy
        )
        let microphoneSettings = SettingsAlertConfiguration(
            title: Localization.Engagement.Alert.Microphone.header,
            message: Localization.Ios.Engagement.Alert.Microphone.message,
            settingsTitle: Localization.Alert.Action.settings,
            cancelTitle: Localization.General.cancel
        )
        let cameraSettings = SettingsAlertConfiguration(
            title: Localization.Engagement.Alert.Camera.header,
            message: Localization.Ios.Engagement.Alert.Camera.message,
            settingsTitle: Localization.Alert.Action.settings,
            cancelTitle: Localization.General.cancel
        )
        let mediaSourceNotAvailable = MessageAlertConfiguration(
            title: Localization.Engagement.Alert.MediaSource.header,
            message: Localization.Ios.Engagement.Alert.MediaSource.message
        )
        let unexpected = MessageAlertConfiguration(
            title: Localization.Error.Unexpected.title,
            message: Localization.Engagement.QueueReconnectionFailed.tryAgain
        )
        let api = MessageAlertConfiguration(
            title: Localization.Error.Unexpected.title,
            message: L10n.Alert.ApiError.message
        )
        let unavailableMessageCenter = MessageAlertConfiguration(
            title: Localization.MessageCenter.Unavailable.title,
            message: Localization.MessageCenter.Unavailable.message,
            shouldShowCloseButton: false
        )

        let unavailableMessageCenterForBeingUnauthenticated = MessageAlertConfiguration(
            title: Localization.MessageCenter.Unavailable.title,
            message: Localization.MessageCenter.NotAuthenticated.message,
            shouldShowCloseButton: false
        )

        let unsupportedGvaBroadcastError = MessageAlertConfiguration(
            title: Localization.Gva.errorUnsupported,
            message: nil
        )

        return AlertConfiguration(
            leaveQueue: leaveQueue,
            endEngagement: endEngagement,
            operatorEndedEngagement: operatorEndedEngagement,
            operatorsUnavailable: operatorsUnavailable,
            mediaUpgrade: mediaUpgrade,
            audioUpgrade: audioUpgrade,
            oneWayVideoUpgrade: oneWayVideoUpgrade,
            twoWayVideoUpgrade: twoWayVideoUpgrade,
            screenShareOffer: screenShareOffer,
            endScreenShare: endScreenShare,
            microphoneSettings: microphoneSettings,
            cameraSettings: cameraSettings,
            mediaSourceNotAvailable: mediaSourceNotAvailable,
            unexpectedError: unexpected,
            apiError: api,
            unavailableMessageCenter: unavailableMessageCenter,
            unavailableMessageCenterForBeingUnauthenticated: unavailableMessageCenterForBeingUnauthenticated,
            unsupportedGvaBroadcastError: unsupportedGvaBroadcastError
        )
    }
}
