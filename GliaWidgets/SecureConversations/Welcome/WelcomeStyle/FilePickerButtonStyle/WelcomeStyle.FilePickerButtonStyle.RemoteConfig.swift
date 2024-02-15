import UIKit

extension SecureConversations.WelcomeStyle.FilePickerButtonStyle {
    mutating func apply(
        configuration: RemoteConfiguration.Color?,
        disabledConfiguration: RemoteConfiguration.Color?
    ) {
        configuration?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { color = $0 }
        disabledConfiguration?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { disabledColor = $0 }
    }
}
