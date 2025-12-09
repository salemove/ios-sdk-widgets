import Combine
import SwiftUI
import UIKit

extension SnackBar {
    static let live: Self = {
        .init { text, style, dismissTiming, viewController, configuration, timerProviding, gcd in
            let existedPresenter = Self.presenters.first(where: { $0.parentViewController === viewController })
            let presenter = existedPresenter ?? Presenter(
                parentViewController: viewController,
                configuration: configuration,
                style: style,
                environment: .init(
                    timerProviding: timerProviding,
                    gcd: gcd
                )
            )
            if existedPresenter == nil {
                Self.presenters.append(presenter)
            }
            presenter.add()
            presenter.show(
                text: text,
                style: style,
                dismissTiming: dismissTiming
            )
        }
    }()

    static private(set) var presenters = [Presenter]()
}
