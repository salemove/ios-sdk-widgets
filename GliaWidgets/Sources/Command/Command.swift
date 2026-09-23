/// Developer-friendly wrapper around a closure.
/// It makes debugging easier by providing callee information.
/// Note: since closure does not conform to `Equatable`, it will
/// also be ignored in `Equatable` and `Hashable` implementations
/// of `Command`.
///
/// Example of declaration and execution:
/// ```
/// let validateEmail = Command<String> { email in /* email validation goes here */ }
/// validateEmail("email@example.test")
/// ```
struct Command<T>: Hashable {
    let tag: String
    let file: String
    let function: String
    let line: UInt
    let closure: (T) -> Void

    init(
        tag: String = "",
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        closure: @escaping (T) -> Void
    ) {
        self.tag = tag
        self.file = "\(file)"
        self.function = "\(function)"
        self.line = line
        self.closure = closure
    }

    func execute(with value: T) {
        closure(value)
    }

    func callAsFunction(_ value: T) {
        execute(with: value)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tag == rhs.tag &&
        lhs.file == rhs.file &&
        lhs.function == rhs.function &&
        lhs.line == rhs.line
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
        hasher.combine(file)
        hasher.combine(function)
        hasher.combine(line)
    }

    /// Command with empty closure.
    static var nop: Self { Self(tag: "nop", closure: { _ in }) }
}

/// A shorthand for Command for closure with zero parameters.
typealias Cmd = Command<Void>

extension Cmd {
    func execute() where T == Void {
        self.execute(with: ())
    }

    func callAsFunction() {
        execute()
    }
}

/// A `Command` whose closure may `await`.
struct AsyncCommand<T>: Hashable {
    let tag: String
    let file: String
    let function: String
    let line: UInt
    let closure: (T) async -> Void

    init(
        tag: String = "",
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        closure: @escaping (T) async -> Void
    ) {
        self.tag = tag
        self.file = "\(file)"
        self.function = "\(function)"
        self.line = line
        self.closure = closure
    }

    func execute(with value: T) async { await closure(value) }
    func callAsFunction(_ value: T) async { await execute(with: value) }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tag == rhs.tag &&
        lhs.file == rhs.file &&
        lhs.function == rhs.function &&
        lhs.line == rhs.line
    }

    func hash(into h: inout Hasher) {
        h.combine(tag); h.combine(file); h.combine(function); h.combine(line)
    }

    static var nop: Self { Self(tag: "nop", closure: { _ in }) }
}

typealias AsyncCmd = AsyncCommand<Void>

extension AsyncCmd {
    func execute() async { await execute(with: ()) }
    func callAsFunction() async { await execute() }
}
