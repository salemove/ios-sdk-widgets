extension Theme {
    var alertConfigurationStyle: AlertConfiguration {
        typealias Alert = L10n.Alert

        let leaveQueue = ConfirmationAlertConfiguration(
            title: Alert.LeaveQueue.title,
            message: Alert.LeaveQueue.message,
            negativeTitle: Alert.Action.no,
            positiveTitle: Alert.Action.yes,
            switchButtonBackgroundColors: true
        )
        let endEngagement = ConfirmationAlertConfiguration(
            title: Alert.EndEngagement.title,
            message: Alert.EndEngagement.message,
            negativeTitle: Alert.Action.no,
            positiveTitle: Alert.Action.yes,
            switchButtonBackgroundColors: true
        )
        let operatorsUnavailable = MessageAlertConfiguration(
            title: Alert.OperatorsUnavailable.title,
            message: Alert.OperatorsUnavailable.message
        )
        let audioAction = MediaUpgradeActionStyle(
            title: Alert.MediaUpgrade.Audio.title,
            titleFont: font.header3,
            titleColor: color.baseDark,
            info: Alert.MediaUpgrade.Audio.info,
            infoFont: font.subtitle,
            infoColor: color.baseDark,
            borderColor: color.primary,
            backgroundColor: color.background,
            icon: Asset.upgradeAudio.image,
            iconColor: color.primary
        )
        let phoneAction = MediaUpgradeActionStyle(
            title: Alert.MediaUpgrade.Phone.title,
            titleFont: font.header3,
            titleColor: color.baseDark,
            info: Alert.MediaUpgrade.Phone.info,
            infoFont: font.subtitle,
            infoColor: color.baseDark,
            borderColor: color.primary,
            backgroundColor: color.background,
            icon: Asset.upgradePhone.image,
            iconColor: color.primary
        )
        let mediaUpgrade = MultipleMediaUpgradeAlertConfiguration(
            title: Alert.MediaUpgrade.title,
            audioUpgradeAction: audioAction,
            phoneUpgradeAction: phoneAction
        )
        let audioUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Alert.AudioUpgrade.title,
            titleImage: Asset.upgradeAudio.image,
            decline: Alert.Action.decline,
            accept: Alert.Action.accept
        )
        let oneWayVideoUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Alert.VideoUpgrade.OneWay.title,
            titleImage: Asset.upgradeVideo.image,
            decline: Alert.Action.decline,
            accept: Alert.Action.accept
        )
        let twoWayVideoUpgrade = SingleMediaUpgradeAlertConfiguration(
            title: Alert.VideoUpgrade.TwoWay.title,
            titleImage: Asset.upgradeVideo.image,
            decline: Alert.Action.decline,
            accept: Alert.Action.accept
        )
        let microphoneSettings = SettingsAlertConfiguration(
            title: Alert.MicrophonePermission.title,
            message: Alert.MicrophonePermission.message,
            settingsTitle: Alert.Action.settings,
            cancelTitle: Alert.Action.cancel
        )
        let cameraSettings = SettingsAlertConfiguration(
            title: Alert.CameraPermission.title,
            message: Alert.CameraPermission.message,
            settingsTitle: Alert.Action.settings,
            cancelTitle: Alert.Action.cancel
        )
        let unexpected = MessageAlertConfiguration(
            title: Alert.Unexpected.title,
            message: Alert.Unexpected.message
        )
        let api = MessageAlertConfiguration(
            title: Alert.ApiError.title,
            message: Alert.ApiError.message
        )

        return AlertConfiguration(
            leaveQueue: leaveQueue,
            endEngagement: endEngagement,
            operatorsUnavailable: operatorsUnavailable,
            mediaUpgrade: mediaUpgrade,
            audioUpgrade: audioUpgrade,
            oneWayVideoUpgrade: oneWayVideoUpgrade,
            twoWayVideoUpgrade: twoWayVideoUpgrade,
            microphoneSettings: microphoneSettings,
            cameraSettings: cameraSettings,
            unexpectedError: unexpected,
            apiError: api
        )
    }
}
