import Foundation
import PhotosUI
import UniformTypeIdentifiers

enum PhotoVideoPickerError: Error {
    case unsupportedFileTypePicked
}

@available(iOS 14, *)
final class PhotoVideoPickerCoordinator: FlowCoordinator {
    enum DelegateEvent {
        case dismiss
        case mediaPicked(URL)
        case error(Error)
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let useCase: PhotoVideoPickerUseCase

    init(useCase: PhotoVideoPickerUseCase) {
        self.useCase = useCase
    }

    func start() -> UIViewController {
        var configuration = PHPickerConfiguration()

        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current
        configuration.filter = .any(of: [.videos, .images])

        let viewController = PHPickerViewController(
            configuration: configuration
        )

        viewController.modalPresentationStyle = .fullScreen
        viewController.delegate = self

        return viewController
    }
}

@available(iOS 14, *)
extension PhotoVideoPickerCoordinator: PHPickerViewControllerDelegate {
    func picker(
        _: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        guard !results.isEmpty else {
            delegate?(.dismiss)
            return
        }

        results.forEach { [weak self] in
            if $0.itemProvider.hasRepresentationConforming(
                toTypeIdentifier: UTType.image.identifier,
                fileOptions: []
            ) {
                self?.useCase.loadUrl(
                    for: UTType.image.identifier,
                    from: $0,
                    success: { [weak self] in
                        self?.delegate?(.mediaPicked($0))
                    },
                    failure: { [weak self] in
                        self?.delegate?(.error($0))
                    }
                )
            } else if $0.itemProvider.hasRepresentationConforming(
                toTypeIdentifier: UTType.movie.identifier,
                fileOptions: []
            ) {
                self?.useCase.loadUrl(
                    for: UTType.movie.identifier,
                    from: $0,
                    success: { [weak self] in
                        self?.delegate?(.mediaPicked($0))
                    },
                   failure: { [weak self] in
                       self?.delegate?(.error($0))
                   }
                )
            } else {
                self?.delegate?(.error(PhotoVideoPickerError.unsupportedFileTypePicked))
            }
        }

        delegate?(.dismiss)
    }
}
