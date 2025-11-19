import UIKit

struct SnackBar {
    var present: (
        _ text: String,
        _ style: Theme.SnackBarStyle,
        _ dismissTiming: SnackBar.DismissTiming,
        _ viewController: UIViewController,
        _ bottomOffset: CGFloat,
        _ timerProviding: FoundationBased.Timer.Providing,
        _ gcd: GCD,
        _ notificationCenter: FoundationBased.NotificationCenter
    ) -> Void

    func present(
        text: String,
        style: Theme.SnackBarStyle,
        dismissTiming: SnackBar.DismissTiming = .default,
        for viewController: UIViewController,
        bottomOffset: CGFloat = 0,
        timerProviding: FoundationBased.Timer.Providing,
        gcd: GCD,
        notificationCenter: FoundationBased.NotificationCenter
    ) {
        present(
            text,
            style,
            dismissTiming,
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
        dismissTiming: SnackBar.DismissTiming = .default,
        topMostViewController: UIViewController,
        timerProviding: FoundationBased.Timer.Providing,
        gcd: GCD,
        notificationCenter: FoundationBased.NotificationCenter
    ) {
        self.present(
            text: text,
            style: style,
            dismissTiming: dismissTiming,
            for: topMostViewController,
            bottomOffset: -60,
            timerProviding: timerProviding,
            gcd: gcd,
            notificationCenter: notificationCenter
        )
    }
}
