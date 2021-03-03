public enum PickedMedia {
    case image(URL)
    case movie(URL)
    case none
}

public enum MediaPickerEvent {
    case none
    case pickedMedia(PickedMedia)
    case sourceNotAvailable
    case noCameraPermission
    case cancelled
}

public final class MediaPickerViewModel: ViewModel {
    public enum MediaSource {
        case camera
        case library
    }

    public enum MediaType {
        case image
        case movie
    }

    public enum Event {
        case sourceNotAvailable
        case noCameraPermission
        case pickedImage(URL)
        case pickedMovie(URL)
        case cancelled
    }

    public enum Action {}

    public enum DelegateEvent {
        case finished
    }

    public var action: ((Action) -> Void)?
    public var delegate: ((DelegateEvent) -> Void)?
    public var source: MediaSource { mediaSource }
    public var types: [MediaType] { mediaTypes }

    private let eventProvider: ValueProvider<MediaPickerEvent>
    private let mediaSource: MediaSource
    private let mediaTypes: [MediaType]

    public init(eventProvider: ValueProvider<MediaPickerEvent>,
                mediaSource: MediaSource,
                mediaTypes: [MediaType] = [.image]) {
        self.eventProvider = eventProvider
        self.mediaSource = mediaSource
        self.mediaTypes = mediaTypes
    }

    public func event(_ event: Event) {
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
