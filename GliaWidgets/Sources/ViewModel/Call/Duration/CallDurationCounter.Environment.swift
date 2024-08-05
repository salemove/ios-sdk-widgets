import Foundation

extension CallDurationCounter {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var date: () -> Date
    }
}

extension CallDurationCounter.Environment {
    static func create(with environment: CallVisualizer.VideoCallViewModel.Environment) -> Self {
        .init(
            timerProviding: environment.timerProviding,
            date: environment.date
        )
    }

    static func create(with environment: CallViewModel.Environment) -> Self {
        .init(
            timerProviding: environment.timerProviding,
            date: environment.date
        )
    }
}
