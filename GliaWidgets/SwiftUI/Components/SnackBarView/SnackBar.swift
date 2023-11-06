import Combine
import SwiftUI
import UIKit

struct SnackBar {
    func present(
        text: String,
        style: Theme.SnackBarStyle,
        for presenter: UIViewController,
        bottomOffset: CGFloat = 0,
        timerProviding: FoundationBased.Timer.Providing
    ) {
        let existedPresenter = Self.presenters.first(where: { $0.parentViewController === presenter })
        let presenter = existedPresenter ?? Presenter(
            parentViewController: presenter,
            style: style,
            environment: .init(timerProviding: timerProviding)
        )
        if existedPresenter == nil {
            Self.presenters.append(presenter)
            presenter.add()
        }
        presenter.show(text: text, with: bottomOffset)
    }

    static private(set) var presenters = [Presenter]()
}
