#if DEBUG

import Foundation

extension CallVisualizer.VisitorCodeViewModel {
    static func mock(
        presentation: CallVisualizer.Presentation,
        environment: CallVisualizer.Environment = .mock,
        theme: Theme = .mock()
    ) -> CallVisualizer.VisitorCodeViewModel {
        CallVisualizer.VisitorCodeViewModel(
            presentation: presentation,
            environment: .init(timerProviding: environment.timerProviding, requestVisitorCode: environment.requestVisitorCode),
            theme: theme,
            delegate: { _ in }
        )
    }
}

#endif
