import UIKit
import GliaWidgets

extension ViewController {

    @IBAction private func presentVisitorCodeAsAlertTapped() {
        Glia.sharedInstance.callVisualizer.showVisitorCodeViewController(from: self)
    }

    @IBAction private func embedVisitorCodeViewTapped() {
        Glia.sharedInstance.callVisualizer.embedVisitorCodeView(
            into: visitorCodeView
        ) {
            self.visitorCodeView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
}
