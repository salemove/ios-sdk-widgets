import UIKit
import GliaWidgets

class SettingsViewController: UIViewController {
    var theme: Theme = Theme()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .white
    }
}
