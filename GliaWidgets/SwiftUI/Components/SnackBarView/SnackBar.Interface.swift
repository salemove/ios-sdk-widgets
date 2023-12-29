import UIKit

struct SnackBar {
    var present: (
        _ text: String,
        _ style: Theme.SnackBarStyle,
        _ viewController: UIViewController,
        _ bottomOffset: CGFloat,
        _ timerProviding: FoundationBased.Timer.Providing,
        _ gcd: GCD
    ) -> Void

    func present(
        text: String,
        style: Theme.SnackBarStyle,
        for viewController: UIViewController,
        bottomOffset: CGFloat = 0,
        timerProviding: FoundationBased.Timer.Providing,
        gcd: GCD
    ) {
        present(
            text,
            style,
            viewController,
            bottomOffset,
            timerProviding,
            gcd
        )
    }
}
