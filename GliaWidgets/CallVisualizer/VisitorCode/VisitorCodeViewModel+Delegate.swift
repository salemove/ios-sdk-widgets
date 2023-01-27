import Foundation

extension CallVisualizer.VisitorCodeViewModel {
    enum Delegate {
        case propsUpdated(CallVisualizer.VisitorCodeViewController.Props)
        case closeButtonTap
    }
}
