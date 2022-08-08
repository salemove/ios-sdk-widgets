import GliaWidgets
import UIKit

final class ViewController: UIViewController {
    @IBOutlet
    private var titleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel?.text = Bundle(for: Glia.self)
            .infoDictionary?["CFBundleShortVersionString"]
            .map { "GliaWidgets: \($0)" }
    }
}
