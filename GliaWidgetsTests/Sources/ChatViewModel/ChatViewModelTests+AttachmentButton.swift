@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import XCTest

extension ChatViewModelTests {
    /// Sending a message clears succeeded uploads, which re-publishes the upload limit.
    /// That signal must not be able to enable the attachment button on its own, otherwise
    /// tapping it opens an empty "File attachments" popover while there is no engagement.
    func test_sendingMessageWhileEnqueuedKeepsAttachmentButtonDisabled() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue.async = { $0() }
        interactorEnv.coreSdk.queueForEngagement = { _, _, _ in }
        interactorEnv.coreSdk.configureWithInteractor = { _ in }
        interactorEnv.coreSdk.sendMessagePreview = { _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        let interactor = Interactor.mock(environment: interactorEnv)

        var viewModelEnv = ChatViewModel.Environment.mock
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.createSendMessagePayload = { _, _ in .mock() }
        viewModelEnv.fetchChatHistory = { $0(.success([])) }
        // The visitor is still waiting in the queue, so no engagement is active
        // and site configuration has not been fetched yet.
        viewModelEnv.getCurrentEngagement = { nil }
        viewModelEnv.fetchSiteConfigurations = { _ in }

        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        let controller = ChatViewController.mock(chatViewModel: viewModel)
        let entryView = try XCTUnwrap((controller.view as? ChatView)?.messageEntryView)

        XCTAssertFalse(entryView.pickMediaButton.isEnabled)

        interactor.state = .enqueued(.mock, .chat)
        viewModel.invokeSetTextAndSendMessage(text: "Test")

        XCTAssertTrue(viewModel.mediaPickerButtonEnabling.isDisabled)
        XCTAssertFalse(
            entryView.pickMediaButton.isEnabled,
            "Attachment button must stay disabled while there is no engagement to attach files to"
        )
    }

    func test_sendingSecureMessageWithoutSiteConfigurationKeepsAttachmentButtonDisabled() throws {
        let environment = SecureConversations.TranscriptModel.Environment.mock(
            createFileUploadListModel: SecureConversations.FileUploadListViewModel.mock(environment:),
            maximumUploads: { 2 }
        )
        let viewModel = SecureConversations.TranscriptModel(
            isCustomCardSupported: false,
            environment: environment,
            availability: .mock(),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: .init(with: 0),
            interactor: .mock()
        )
        let controller = ChatViewController(
            viewModel: .transcript(viewModel),
            environment: .mock()
        )
        let entryView = try XCTUnwrap((controller.view as? ChatView)?.messageEntryView)

        XCTAssertFalse(entryView.pickMediaButton.isEnabled)

        viewModel.event(.messageTextChanged("Test"))
        viewModel.event(.sendTapped)

        XCTAssertTrue(viewModel.mediaPickerButtonEnabling.isDisabled)
        XCTAssertFalse(entryView.pickMediaButton.isEnabled)
    }

    func test_mediaPickerButtonEnablingRespectsUploadLimit() throws {
        var environment = ChatViewModel.Environment.mock
        let site = try CoreSdkClient.Site.mock(
            allowedFileContentTypes: ["image/jpeg"],
            allowedFileSenders: .mock(visitor: true)
        )
        environment.fetchSiteConfigurations = { $0(.success(site)) }
        environment.getCurrentEngagement = { .mock() }
        let viewModel = ChatViewModel.mock(
            environment: environment,
            maximumUploads: { 1 }
        )
        viewModel.fetchSiteConfigurations()

        XCTAssertFalse(viewModel.mediaPickerButtonEnabling.isDisabled)

        let upload = try XCTUnwrap(viewModel.fileUploadListModel.addUpload(with: .mock))

        XCTAssertTrue(viewModel.fileUploadListModel.isLimitReached)
        XCTAssertTrue(viewModel.mediaPickerButtonEnabling.isDisabled)

        viewModel.fileUploadListModel.removeUpload(upload)

        XCTAssertFalse(viewModel.fileUploadListModel.isLimitReached)
        XCTAssertFalse(viewModel.mediaPickerButtonEnabling.isDisabled)
    }

    func test_swappingModelsRefreshesAttachmentButtonEnabling() throws {
        let initialViewModel = ChatViewModel.mock()
        let controller = ChatViewController.mock(chatViewModel: initialViewModel)
        let entryView = try XCTUnwrap((controller.view as? ChatView)?.messageEntryView)
        initialViewModel.action?(
            .setAttachmentButtonEnabling(.enabled(.secureMessaging))
        )
        XCTAssertTrue(entryView.pickMediaButton.isEnabled)

        let replacementViewModel = ChatViewModel.mock()
        controller.swapAndBindViewModel(.chat(replacementViewModel))

        XCTAssertTrue(replacementViewModel.mediaPickerButtonEnabling.isDisabled)
        XCTAssertFalse(entryView.pickMediaButton.isEnabled)
    }

    /// An attachment popover with no sources renders as a blank sheet, so it must not be shown.
    func test_popoverIsNotPresentedWhenNoAttachmentSourcesAreAllowed() {
        final class PresentationSpy: UIViewController, PopoverPresenter {
            private(set) var presentedControllers: [UIViewController] = []
            override func present(
                _ viewControllerToPresent: UIViewController,
                animated: Bool,
                completion: (() -> Void)? = nil
            ) {
                presentedControllers.append(viewControllerToPresent)
            }
        }

        let presenter = PresentationSpy()
        let style = Theme().chatStyle.pickMedia

        presenter.presentPopover(
            with: style,
            from: presenter.view,
            options: [],
            itemSelected: { _ in }
        )
        XCTAssertTrue(presenter.presentedControllers.isEmpty)

        presenter.presentPopover(
            with: style,
            from: presenter.view,
            options: [.browse],
            itemSelected: { _ in }
        )
        XCTAssertEqual(presenter.presentedControllers.count, 1)
    }
}
