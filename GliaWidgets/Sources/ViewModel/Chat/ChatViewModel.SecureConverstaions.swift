import SalemoveSDK

extension ChatViewModel {
    func migrate(from transcript: SecureConversations.TranscriptModel) {
        sections = transcript.sections
        // There's a possibility where migration to engagement
        // happens when there are awaiting uploads.
        // For that case we need to make sure that theses uploads
        // have also migrated to use engagement based API.
        fileUploadListModel.environment.uploader.uploads = transcript
            .fileUploadListModel
            .environment
            .uploader
            .uploads
            .map { [environment] upload in
                upload.environment.uploadFile = .toEngagement(environment.uploadFileToEngagement)
                return upload
            }
        // Since we have modified file upload list view model,
        // we need to report about this change manually
        // to keep UI in sync with data.
        fileUploadListModel.reportChange()
        isViewLoaded = transcript.isViewLoaded
        // Keep state of view-model in sync with Interactor.
        interactorEvent(.stateChanged(interactor.state))
        action?(.scrollToBottom(animated: true))
        // Set view active, to avoid unread message button
        // to be shown.
        isViewActive.value = true

        environment.stopSocketObservation()
        loadHistory(appendingToMessageSection: true) { [weak self] _ in
            self?.environment.startSocketObservation()
        }
    }
}
