import Combine
import SwiftUI
import UIKit

struct SnackBar {
    func present(
        text: String,
        style: Theme.SnackBarStyle,
        for viewController: UIViewController,
        bottomOffset: CGFloat = 0,
        timerProviding: FoundationBased.Timer.Providing,
        gcd: GCD
    ) {
        let existedPresenter = Self.presenters.first(where: { $0.parentViewController === viewController })
        let presenter = existedPresenter ?? Presenter(
            parentViewController: viewController,
            style: style,
            environment: .init(timerProviding: timerProviding, gcd: gcd)
        )
        if existedPresenter == nil {
            Self.presenters.append(presenter)
        }
        presenter.add()
        presenter.show(text: text, with: bottomOffset)
    }

    static private(set) var presenters = [Presenter]()
}
