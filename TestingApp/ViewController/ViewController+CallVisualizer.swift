import UIKit
import GliaWidgets

extension ViewController {

    @IBAction private func presentVisitorCodeAsAlertTapped() {
        Glia.sharedInstance.callVisualizer.showVisitorCodeViewController(
            by: .alert(self)
        )
    }

    @IBAction private func embedVisitorCodeViewTapped() {
        Glia.sharedInstance.callVisualizer.showVisitorCodeViewController(
            by: .embedded(
                visitorCodeView,
                onEngagementAccepted: {
                    self.visitorCodeView.subviews.forEach { $0.removeFromSuperview() }
                }
            )
        )
    }
}
