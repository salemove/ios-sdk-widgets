func unavailable(function: StaticString = #function) -> Never {
    fatalError("This implementation for \(function) is not longer available.")
}
