import Combine
import SwiftUI
import UIKit

extension SnackBar {
    static let live: Self = {
        .init { text, style, dismissTiming, viewController, bottomOffset, timerProviding, gcd, notificationCenter in
            let existedPresenter = Self.presenters.first(where: { $0.parentViewController === viewController })
            let presenter = existedPresenter ?? Presenter(
                parentViewController: viewController,
                style: style,
                environment: .init(
                    timerProviding: timerProviding,
                    notificationCenter: notificationCenter,
                    gcd: gcd
                )
            )
            if existedPresenter == nil {
                Self.presenters.append(presenter)
            }
            presenter.add()
            presenter.show(text: text, with: bottomOffset, dismissTiming: dismissTiming)
        }
    }()
    static private(set) var presenters = [Presenter]()
}
