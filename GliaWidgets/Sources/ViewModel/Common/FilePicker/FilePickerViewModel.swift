import Foundation
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
                    "public.content",
                    "public.data",
                    "public.archive",
                    "public.image",
                    "public.text"
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

    private let pickerEvent: ObservableValue<FilePickerEvent>
    var environment: Environment

    init(
        pickerEvent: ObservableValue<FilePickerEvent>,
        allowedFiles: FileTypes = .default,
        environment: Environment
    ) {
        self.pickerEvent = pickerEvent
        self.allowedFiles = allowedFiles
        self.environment = environment
    }

    func event(_ event: Event) {
        switch event {
        case .pickedFile(let url):
            pickerEvent.value = .pickedFile(url)
            delegate?(.finished)
        case .cancelled:
            pickerEvent.value = .cancelled
            delegate?(.finished)
        }
    }
}

extension FilePickerViewModel {
    struct Environment {
        var log: CoreSdkClient.Logger
    }
}
