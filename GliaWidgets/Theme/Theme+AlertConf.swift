extension Theme {
    var alertConfStyle: AlertConf {
        typealias Alert = L10n.Alert

        let leaveQueue = ConfirmationAlertConf(title: Alert.LeaveQueue.title,
                                               message: Alert.LeaveQueue.message,
                                               negativeTitle: Alert.Action.no,
                                               positiveTitle: Alert.Action.yes)
        let endEngagement = ConfirmationAlertConf(title: Alert.EndEngagement.title,
                                                  message: Alert.EndEngagement.message,
                                                  negativeTitle: Alert.Action.no,
                                                  positiveTitle: Alert.Action.yes)
        let operatorsUnavailable = MessageAlertConf(title: Alert.OperatorsUnavailable.title,
                                                    message: Alert.OperatorsUnavailable.message)
        let audioAction = MediaUpgradeActionStyle(title: Alert.MediaUpgrade.Audio.title,
                                                  titleFont: font.header3,
                                                  titleColor: color.baseDark,
                                                  info: Alert.MediaUpgrade.Audio.info,
                                                  infoFont: font.subtitle,
                                                  infoColor: color.baseDark,
                                                  borderColor: color.primary,
                                                  backgroundColor: color.background,
                                                  icon: Asset.upgradeAudio.image,
                                                  iconColor: color.primary)
        let phoneAction = MediaUpgradeActionStyle(title: Alert.MediaUpgrade.Phone.title,
                                                  titleFont: font.header3,
                                                  titleColor: color.baseDark,
                                                  info: Alert.MediaUpgrade.Phone.info,
                                                  infoFont: font.subtitle,
                                                  infoColor: color.baseDark,
                                                  borderColor: color.primary,
                                                  backgroundColor: color.background,
                                                  icon: Asset.upgradePhone.image,
                                                  iconColor: color.primary)
        let mediaUpgrade = MediaUpgradeAlertConf(title: Alert.MediaUpgrade.title,
                                                 audioUpgradeAction: audioAction,
                                                 phoneUpgradeAction: phoneAction)
        let audioUpgrade = AudioUpgradeAlertConf(title: Alert.AudioUpgrade.title,
                                                 titleImage: Asset.upgradeAudio.image,
                                                 decline: Alert.Action.decline,
                                                 accept: Alert.Action.accept)
        let microphoneSettings = SettingsAlertConf(title: Alert.MicrophonePermission.title,
                                                   message: Alert.MicrophonePermission.message,
                                                   settingsTitle: Alert.Action.settings,
                                                   cancelTitle: Alert.Action.cancel)
        let unexpected = MessageAlertConf(title: Alert.Unexpected.title,
                                          message: Alert.Unexpected.message)
        let api = MessageAlertConf(title: Alert.ApiError.title,
                                   message: Alert.ApiError.message)

        return AlertConf(leaveQueue: leaveQueue,
                        endEngagement: endEngagement,
                        operatorsUnavailable: operatorsUnavailable,
                        mediaUpgrade: mediaUpgrade,
                        audioUpgrade: audioUpgrade,
                        microphoneSettings: microphoneSettings,
                        unexpectedError: unexpected,
                        apiError: api)
    }
}
