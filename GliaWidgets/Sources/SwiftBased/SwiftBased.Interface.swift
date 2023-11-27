/// Namespace for managed dependencies from `Swift` namespace.
enum SwiftBased {
    /// Managed dependency for `Swift.print`
    struct Print {
        var printClosure: (_ item: Any, _ separator: String, _ terminator: String) -> Void

        func print(_ item: Any, separator: String = " ", terminator: String = "\n") {
            printClosure(item, separator, terminator)
        }

        func callAsFunction(_ item: Any, separator: String = " ", terminator: String = "\n") {
            print(item, separator: separator, terminator: terminator)
        }
    }
}
