enum PickedMedia {
    case image(URL)
    case photo(Data, format: MediaFormat)
    case movie(URL)
    case none
}

enum MediaFormat {
    case jpeg(quality: Float)

    var fileExtension: String {
        switch self {
        case .jpeg:
            return "jpeg"
        }
    }
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
        case pickedPhoto(Data, format: MediaFormat)
        case pickedMovie(URL)
        case cancelled
    }

    enum Action {}

    enum DelegateEvent {
        case finished
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?
    var source: MediaSource { return mediaSource }
    var types: [MediaType] { return mediaTypes }
    var photoFormat: MediaFormat { return .jpeg(quality: 0.8) }

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
        case .pickedPhoto(let data, format: let format):
            pickerEvent.value = .pickedMedia(.photo(data, format: format))
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
