enum PickedMedia {
    case image(URL)
    case movie(URL)
    case none
}

enum MediaPickerEvent {
    case none
    case pickedMedia(PickedMedia)
    case sourceNotAvailable
    case noCameraPermission
    case cancelled
}

class MediaPickerViewModel: ViewModel {
    enum MediaSource {
        case camera
        case library
    }

    enum MediaType {
        case image
        case movie
    }

    enum Event {
        case sourceNotAvailable
        case noCameraPermission
        case pickedImage(URL)
        case pickedMovie(URL)
        case cancelled
    }

    enum Action {}

    enum DelegateEvent {
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?
    var source: MediaSource { mediaSource }
    var types: [MediaType] { mediaTypes }

    private let pickerEvent: ObservableValue<MediaPickerEvent>
    private let mediaSource: MediaSource
    private let mediaTypes: [MediaType]

    init(pickerEvent: ObservableValue<MediaPickerEvent>,
         mediaSource: MediaSource,
         mediaTypes: [MediaType] = [.image]) {
        self.pickerEvent = pickerEvent
        self.mediaSource = mediaSource
        self.mediaTypes = mediaTypes
    }

    func event(_ event: Event) {
        switch event {
        case .sourceNotAvailable:
            pickerEvent.value = .sourceNotAvailable
            delegate?(.finished)
        case .noCameraPermission:
            pickerEvent.value = .noCameraPermission
            delegate?(.finished)
        case .pickedImage(let url):
            pickerEvent.value = .pickedMedia(.image(url))
            delegate?(.finished)
        case .pickedMovie(let url):
            pickerEvent.value = .pickedMedia(.movie(url))
            delegate?(.finished)
        case .cancelled:
            pickerEvent.value = .cancelled
            delegate?(.finished)
        }
    }
}
