import UIKit

struct SnackBar {
    var present: (
        _ text: String,
        _ style: Theme.SnackBarStyle,
        _ viewController: UIViewController,
        _ bottomOffset: CGFloat,
        _ timerProviding: FoundationBased.Timer.Providing,
        _ gcd: GCD,
        _ notificationCenter: FoundationBased.NotificationCenter
    ) -> Void

    func present(
        text: String,
        style: Theme.SnackBarStyle,
        for viewController: UIViewController,
        bottomOffset: CGFloat = 0,
        timerProviding: FoundationBased.Timer.Providing,
        gcd: GCD,
        notificationCenter: FoundationBased.NotificationCenter
    ) {
        present(
            text,
            style,
            viewController,
            bottomOffset,
            timerProviding,
            gcd,
            notificationCenter
        )
    }

    func showSnackBarMessage(
        text: String,
        style: Theme.SnackBarStyle,
        topMostViewController: UIViewController,
        timerProviding: FoundationBased.Timer.Providing,
        gcd: GCD,
        notificationCenter: FoundationBased.NotificationCenter
    ) {
        self.present(
            text: text,
            style: style,
            for: topMostViewController,
            bottomOffset: -60,
            timerProviding: timerProviding,
            gcd: gcd,
            notificationCenter: notificationCenter
        )
    }
}
