import PhotosUI

@available(iOS 14, *)
protocol PhotoVideoPickerUseCase {
    func loadUrl(
        for identifier: String,
        from result: PHPickerResult,
        success: @escaping ((URL) -> Void),
        failure: @escaping ((Error) -> Void)
    )
}

@available(iOS 14, *)
final class PhotoVideoPickerUseCaseImpl: PhotoVideoPickerUseCase {
    private let dataStorage: DataStorage

    init(dataStorage: DataStorage) {
        self.dataStorage = dataStorage
    }

    private func savePickedMedia(url: URL) -> URL? {
        do {
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            let key = "\(UUID().uuidString)/\(url.lastPathComponent)"

            dataStorage.store(data, for: key)

            return dataStorage.url(for: key)
        } catch {
            return nil
        }
    }

    func loadUrl(
        for identifier: String,
        from result: PHPickerResult,
        success: @escaping ((URL) -> Void),
        failure: @escaping ((Error) -> Void)
    ) {
        result.itemProvider.loadFileRepresentation(
            forTypeIdentifier: identifier,
            completionHandler: { [weak self] url, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    if let error = error {
                        failure(error)
                    } else if
                        let url = url,
                        let storedUrl = self.savePickedMedia(url: url)
                    {
                        success(storedUrl)
                    }
                }
            }
        )
    }
}
