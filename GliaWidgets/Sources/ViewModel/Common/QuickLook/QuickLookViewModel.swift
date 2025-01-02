import Foundation
import QuickLook

class QuickLookViewModel: ViewModel {
    enum Event {
        case dismissed
    }

    enum Action {}

    enum DelegateEvent {
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let items: [QLPreviewItem]
    var environment: Environment

    init(files: [LocalFile], environment: Environment) {
        self.items = files.map { $0.url as NSURL }
        self.environment = environment
    }

    convenience init(file: LocalFile, environment: Environment) {
        self.init(files: [file], environment: environment)
    }

    func event(_ event: Event) {
        switch event {
        case .dismissed:
            delegate?(.finished)
        }
    }
}

extension QuickLookViewModel {
    var numOfItems: Int { return items.count }

    func item(at index: Int) -> QLPreviewItem {
        return items[index]
    }
}
