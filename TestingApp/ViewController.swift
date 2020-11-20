import UIKit
import GliaWidgets

class ViewController: UIViewController {
    private var glia: Glia?

    override func viewDidLoad() {
        super.viewDidLoad()

        let conf = Configuration(applicationToken: "",
                                 apiToken: "",
                                 environment: .europe,
                                 site: "")
        glia = Glia(configuration: conf)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var theme = Theme()
        theme.primaryColor = .red
        theme.chatStyle.primaryColor = .blue
        glia?.start(.chat, from: self, using: theme)
    }
}
