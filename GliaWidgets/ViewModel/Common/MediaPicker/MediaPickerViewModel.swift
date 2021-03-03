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

    private let eventProvider: ValueProvider<MediaPickerEvent>
    private let mediaSource: MediaSource
    private let mediaTypes: [MediaType]

    init(eventProvider: ValueProvider<MediaPickerEvent>,
         mediaSource: MediaSource,
         mediaTypes: [MediaType] = [.image]) {
        self.eventProvider = eventProvider
        self.mediaSource = mediaSource
        self.mediaTypes = mediaTypes
    }

    func event(_ event: Event) {
        switch event {
        case .sourceNotAvailable:
            eventProvider.value = .sourceNotAvailable
            delegate?(.finished)
        case .noCameraPermission:
            eventProvider.value = .noCameraPermission
            delegate?(.finished)
        case .pickedImage(let url):
            eventProvider.value = .pickedMedia(.image(url))
            delegate?(.finished)
        case .pickedMovie(let url):
            eventProvider.value = .pickedMedia(.movie(url))
            delegate?(.finished)
        case .cancelled:
            eventProvider.value = .cancelled
            delegate?(.finished)
        }
    }
}
