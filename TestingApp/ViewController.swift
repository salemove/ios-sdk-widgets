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
        glia?.start(.chat, presentation: .presentFrom(self))
    }
}
