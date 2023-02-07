import UIKit.UIContentSizeCategory

extension SecureConversations {
    class FileUploadListViewModel: ViewModel {
        typealias Create = (Environment) -> FileUploadListViewModel

        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?

        enum Event {}
        enum Action {}

        enum DelegateEvent {
            case renderProps(SecureConversations.FileUploadListView.Props)
        }

        let environment: Environment

        init(environment: Environment) {
            self.environment = environment
            environment.uploader.state.addObserver(self) { [weak self] state, _ in
                self?.onUploaderStateChanged(state)
            }
            environment.uploader.limitReached.addObserver(self) { [weak self] limitReached, _ in
                // TODO: MOB-1838
            }
        }

        func event(_ event: Event) {}

        func reportChange() {
            delegate?(.renderProps(props()))
        }

        func observeUpload(
            _ upload: FileUpload,
            instance: FileUploadListViewModel
        ) {
            // We need to observe state of the FileUpload,
            // and trigger Props generation.
            var progressObservable: ObservableValue<Double>?

            func handleState(
                _ state: FileUpload.State,
                instance: FileUploadListViewModel
            ) {
                progressObservable?.removeObserver(instance)
                switch state {
                case .none, .uploaded, .error:
                    break
                case .uploading(progress: let progress):
                    progressObservable = progress
                    progressObservable?.addObserver(instance) { [weak instance] _, _ in
                        instance?.reportChange()
                    }
                }

                instance.reportChange()
            }

            upload.state.addObserver(instance) { [weak instance] state, _ in
                guard let instance = instance else { return }
                handleState(state, instance: instance)
            }

            // There is a case, where state is already set to `.uploading` case,
            // that's why we evaluate state immediatelty.
            handleState(upload.state.value, instance: instance)
        }

        func onUploaderStateChanged(_ state: FileUploader.State) {
            reportChange()
        }

        func removeUpload(_ upload: FileUpload) {
            upload.state.removeObserver(self)
            environment.uploader.removeUpload(upload)
            reportChange()
        }

        func props() -> FileUploadListView.Props {
            typealias Identifier = SecureConversations.FileUploadListView.FileUploadView.Props.Identifier
            typealias FileUploadViewProps = SecureConversations.FileUploadListView.FileUploadView.Props

            let uploads = IdCollection<Identifier, FileUploadViewProps>(
                environment.uploader.uploads.map { fileUpload in
                    FileUploadViewProps(
                        fileUpload: fileUpload,
                        style: environment.style.item,
                        removeTapped: Cmd { [weak self] in
                            self?.removeUpload(fileUpload)
                        }
                    )
                }
            )

            var maxUnscrollableViews: Int {
                if environment.uiApplication.preferredContentSizeCategory() <= .accessibilityMedium {
                    return .maxUnscrollableViewsOnDefaultContentSizeCategory
                } else {
                    return .maxUnscrollableViewsOnLargeContentSizeCategory
                }
            }

            let props = FileUploadListView.Props(
                maxUnscrollableViews: maxUnscrollableViews,
                style: environment.style,
                uploads: uploads
            )
            return props
        }
    }
}

// MARK: - Compatibility extension for ChatViewModel
extension SecureConversations.FileUploadListViewModel {
    var attachment: CoreSdkClient.Attachment? {
        environment.uploader.attachment
    }

    var succeededUploads: [FileUpload] {
        environment.uploader.succeededUploads
    }

    var failedUploads: [FileUpload] {
        environment.uploader.failedUploads
    }

    var state: ObservableValue<FileUploader.State> {
        environment.uploader.state
    }

    func removeSucceededUploads() {
        environment.uploader.removeSucceededUploads()
        reportChange()
    }

    @discardableResult
    func addUpload(with url: URL) -> FileUpload? {
        guard let upload = environment.uploader.addUpload(with: url) else {
            return nil
        }
        return handleAddedUpload(upload)

    }

    @discardableResult
    func addUpload(with data: Data, format: MediaFormat) -> FileUpload? {
        guard let upload = environment.uploader.addUpload(with: data, format: format) else {
            return nil
        }

        return handleAddedUpload(upload)
    }

    func handleAddedUpload(_ upload: FileUpload) -> FileUpload {
        observeUpload(upload, instance: self)
        reportChange()
        return upload
    }
}

#if DEBUG
extension SecureConversations.FileUploadListViewModel {
    static func mock(environment: Environment = .mock) -> SecureConversations.FileUploadListViewModel {
        .init(environment: environment)
    }
}
#endif

private extension Int {
    static let maxUnscrollableViewsOnDefaultContentSizeCategory = 3
    static let maxUnscrollableViewsOnLargeContentSizeCategory = 2
}
