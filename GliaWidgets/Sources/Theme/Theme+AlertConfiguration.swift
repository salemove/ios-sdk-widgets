extension Theme {
    var alertConfigurationStyle: AlertConfiguration {
        let leaveQueue = ConfirmationAlertConfiguration(
            title: Localization.Engagement.Queue.Leave.header,
            message: Localization.Engagement.Queue.Leave.message,
            negativeTitle: Localization.General.no,
            positiveTitle: Localization.General.yes,
            switchButtonBackgroundColors: true,
            showsPoweredBy: showsPoweredBy
        )
        let endEngagement = ConfirmationAlertConfiguration(
            title: Localization.Engagement.End.Confirmation.header,
            message: Localization.Engagement.End.message,
            negativeTitle: Localization.General.no,
            positiveTitle: Localization.General.yes,
            switchButtonBackgroundColors: true,
            showsPoweredBy: showsPoweredBy
        )
        let operatorEndedEngagement = SingleActionAlertConfiguration(
            title: Localization.Engagement.Ended.header,
            message: Localization.Engagement.Ended.message,
            buttonTitle: Localization.General.ok
        )
        let endScreenShare = ConfirmationAlertConfiguration(
            title: Localization.Alert.ScreenSharing.Stop.header,
            message: Localization.Alert.ScreenSharing.Stop.message,
            negativeTitle: Localization.General.no,
            positiveTitle: Localization.General.yes,
            switchButtonBackgroundColors: true,
            showsPoweredBy: showsPoweredBy
        )
        let operatorsUnavailable = MessageAlertConfiguration(
            title: Localization.Engagement.Queue.Closed.header,
            message: Localization.Engagement.Queue.Closed.message
        )
        let audioAction = MediaUpgradeActionStyle(
            title: Localization.Engagement.Audio.title,
            titleFont: font.header3,
            titleColor: color.baseDark,
            info: Localization.Engagement.MediaUpgrade.Audio.info,
            infoFont: font.subtitle,
            infoColor: color.baseDark,
            borderColor: color.primary,
            backgroundColor: color.baseLight,
            icon: Asset.upgradeAudio.image,
            iconColor: color.primary
        )
        let phoneAction = MediaUpgradeActionStyle(
            title: Localization.Engagement.Phone.title,
            titleFont: font.header3,
            titleColor: color.baseDark,
            info: Localization.Engagement.MediaUpgrade.Phone.info,
            infoFont: font.subtitle,
            infoColor: color.baseDark,
            borderColor: color.primary,
            backgroundColor: color.baseLight,
            icon: Asset.upgradePhone.image,
            iconColor: color.primary
        )
        let mediaUpgrade = MultipleMediaUpgradeAlertConfiguration(
            title: Localization.Engagement.MediaUpgrade.offer,
            audioUpgradeAction: audioAction,
            phoneUpgradeAction: phoneAction,
            showsPoweredBy: showsPoweredBy
        )
        let audioUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Localization.MediaUpgrade.Audio.title,
            titleImage: Asset.upgradeAudio.image,
            decline: Localization.General.decline,
            accept: Localization.General.accept,
            showsPoweredBy: showsPoweredBy
        )
        let oneWayVideoUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Localization.MediaUpgrade.Video.OneWay.title,
            titleImage: Asset.upgradeVideo.image,
            decline: Localization.General.decline,
            accept: Localization.General.accept,
            showsPoweredBy: showsPoweredBy
        )
        let twoWayVideoUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Localization.MediaUpgrade.Video.TwoWay.title,
            titleImage: Asset.upgradeVideo.image,
            decline: Localization.General.decline,
            accept: Localization.General.accept,
            showsPoweredBy: showsPoweredBy
        )
        let screenShareOffer = ScreenShareOfferAlertConfiguration(
            title: Localization.Alert.ScreenSharing.Start.header,
            message: Localization.Alert.ScreenSharing.Start.message,
            titleImage: Asset.startScreenShare.image,
            decline: Localization.General.decline,
            accept: Localization.General.accept,
            showsPoweredBy: showsPoweredBy
        )
        let microphoneSettings = SettingsAlertConfiguration(
            title: Localization.Alert.MicrophoneAccess.error,
            message: Localization.Ios.Alert.MicrophoneAccess.message,
            settingsTitle: Localization.Alert.Action.settings,
            cancelTitle: Localization.General.cancel
        )
        let cameraSettings = SettingsAlertConfiguration(
            title: Localization.Alert.CameraAccess.error,
            message: Localization.Ios.Alert.CameraAccess.message,
            settingsTitle: Localization.Alert.Action.settings,
            cancelTitle: Localization.General.cancel
        )
        let mediaSourceNotAvailable = MessageAlertConfiguration(
            title: Localization.Alert.MediaSourceAccess.error,
            message: Localization.Ios.Alert.MediaSource.message
        )
        let unexpected = MessageAlertConfiguration(
            title: Localization.Error.unexpected,
            message: Localization.Engagement.Queue.Reconnection.failed
        )
        let api = MessageAlertConfiguration(
            title: Localization.Error.unexpected,
            message: Localization.Templates.errorMessage
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
            title: Localization.Gva.UnsupportedAction.error,
            message: nil
        )

        let expiredAccessTokenError = MessageAlertConfiguration(
            title: Localization.Ios.Alert.ExpiredAccessToken.title,
            message: Localization.Ios.Alert.ExpiredAccessToken.message
        )

        let liveObservationConfirmation = ConfirmationAlertConfiguration(
            title: Localization.Engagement.Confirm.title,
            message: Localization.Engagement.Confirm.message,
            firstLinkButtonUrl: Localization.Engagement.Confirm.Link1.url,
            secondLinkButtonUrl: Localization.Engagement.Confirm.Link2.url,
            negativeTitle: Localization.General.cancel,
            positiveTitle: Localization.General.allow,
            switchButtonBackgroundColors: true,
            showsPoweredBy: showsPoweredBy
        )

        let leaveCurrentConversation = ConfirmationAlertConfiguration(
            title: Localization.SecureMessaging.Chat.LeaveCurrentConversation.title,
            message: Localization.SecureMessaging.Chat.LeaveCurrentConversation.message,
            negativeTitle: Localization.SecureMessaging.Chat.LeaveCurrentConversation.Button.negative,
            positiveTitle: Localization.SecureMessaging.Chat.LeaveCurrentConversation.Button.positive,
            switchButtonBackgroundColors: false,
            showsPoweredBy: showsPoweredBy
        )

        let pushNotificationsPermissions = ConfirmationAlertConfiguration(
            title: Localization.PushNotificationsAlert.title,
            message: Localization.PushNotificationsAlert.message,
            negativeTitle: Localization.PushNotificationsAlert.Button.negative,
            positiveTitle: Localization.PushNotificationsAlert.Button.positive,
            switchButtonBackgroundColors: false,
            showsPoweredBy: showsPoweredBy
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
            unsupportedGvaBroadcastError: unsupportedGvaBroadcastError,
            liveObservationConfirmation: liveObservationConfirmation,
            expiredAccessTokenError: expiredAccessTokenError,
            leaveCurrentConversation: leaveCurrentConversation,
            pushNotificationsPermissions: pushNotificationsPermissions
        )
    }
}
