import GliaWidgets
import Foundation

extension SettingsViewController {
    struct Props {
        let config: Configuration
        let changeConfig: (Configuration) -> Void

        let queueId: String
        let changeQueueId: (String) -> Void

        let theme: Theme
        let changeTheme: (Theme) -> Void
        
        let features: Features
        let changeFeatures: (Features) -> Void
    }
}
