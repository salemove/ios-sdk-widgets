public enum PickedMedia {
    case image(URL)
    case movie(URL)
    case none
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

    private let mediaProvider: ValueProvider<PickedMedia>
    private let mediaSource: MediaSource
    private let mediaTypes: [MediaType]

    public init(provider: ValueProvider<PickedMedia>,
                source: MediaSource,
                types: [MediaType] = [.image]) {
        mediaProvider = provider
        mediaSource = source
        mediaTypes = types
    }

    public func event(_ event: Event) {
        switch event {
        case .noCameraPermission:
            delegate?(.finished)
        case .pickedImage(let url):
            mediaProvider.value = .image(url)
            delegate?(.finished)
        case .pickedMovie(let url):
            mediaProvider.value = .movie(url)
            delegate?(.finished)
        case .cancelled:
            delegate?(.finished)
        }
    }
}
