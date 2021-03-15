import MobileCoreServices

enum FilePickerEvent {
    case none
    case pickedFile(URL)
    case cancelled
}

class FilePickerViewModel: ViewModel {
    enum FileTypes {
        case `default`
        case custom([String])

        var types: [String] {
            switch self {
            case .default:
                return [
                    "public.data",
                    "public.image",
                    "public.movie"
                ]
            case .custom(let types):
                return types
            }
        }
    }

    enum Event {
        case pickedFile(URL)
        case cancelled
    }

    enum Action {}

    enum DelegateEvent {
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    let allowedFiles: FileTypes

    private let eventProvider: ValueProvider<FilePickerEvent>

    init(eventProvider: ValueProvider<FilePickerEvent>,
         allowedFiles: FileTypes = .default) {
        self.eventProvider = eventProvider
        self.allowedFiles = allowedFiles
    }

    func event(_ event: Event) {
        switch event {
        case .pickedFile(let url):
            eventProvider.value = .pickedFile(url)
            delegate?(.finished)
        case .cancelled:
            eventProvider.value = .cancelled
            delegate?(.finished)
        }
    }
}
