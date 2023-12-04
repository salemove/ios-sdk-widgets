import Foundation

extension ChatViewController {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var viewFactory: ViewFactory
        var gcd: GCD
    }
}