import UIKit
import GliaCoreSDK

struct SnackBar {
    var present: (
        _ text: String,
        _ style: Theme.SnackBarStyle,
        _ dismissTiming: SnackBar.DismissTiming,
        _ viewController: UIViewController,
        _ configuration: SnackBar.Configuration,
        _ timerProviding: FoundationBased.Timer.Providing,
        _ gcd: GCD
    ) -> Void

    func present(
        text: String,
        style: Theme.SnackBarStyle,
        dismissTiming: SnackBar.DismissTiming = .default,
        for viewController: UIViewController,
        configuration: SnackBar.Configuration,
        timerProviding: FoundationBased.Timer.Providing,
        gcd: GCD
    ) {
        present(
            text,
            style,
            dismissTiming,
            viewController,
            configuration,
            timerProviding,
            gcd
        )
    }
}

extension SnackBar {
    struct Key: DependencyKey {
        static var live: SnackBar = .live

        static var test: SnackBar = .mock
    }
}

extension DependencyContainer.Widgets {
    var snackBar: SnackBar {
        get { self[SnackBar.Key.self] }
        set { self[SnackBar.Key.self] = newValue }
    }
}
