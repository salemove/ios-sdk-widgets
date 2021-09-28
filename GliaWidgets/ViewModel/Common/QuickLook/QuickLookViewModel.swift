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

    private let items: [QuickLookPreviewItem]

    init(files: [LocalFile]) {
        self.items = files.map { .init(url: $0.url, title: $0.fileName) }
    }

    convenience init(file: LocalFile) {
        self.init(files: [file])
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
