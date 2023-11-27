extension SwiftBased.Print {
    /// Live instance of `Print`.
    static let live = Self(
        printClosure: {
            Swift.print($0, separator: $1, terminator: $2)
        }
    )
}
