import Foundation

extension CallViewModel {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var date: () -> Date
    }
}
