import Foundation

final class Disposable {
    let dispose: () -> Void

    init(_ dispose: @escaping () -> Void) {
        self.dispose = dispose
    }

    deinit {
        dispose()
    }

    func add(to disposal: inout [Disposable]) {
        disposal.append(self)
    }
}
