import Foundation
import XCTest
@testable import GliaWidgets

final class SecureConversationsWelcomeViewModelTests: XCTestCase {
    typealias WelcomeViewModel = SecureConversations.WelcomeViewModel
    var viewModel: WelcomeViewModel!

    override func setUp() {
        viewModel = .mock
    }

    override func tearDown() {
        viewModel = nil
    }
}

// Delegates
extension SecureConversationsWelcomeViewModelTests {
    func testDelegateGetsCalledOnBackTapped() {
        var isCalled = false

        viewModel.delegate = { event in
            switch event {
            case .backTapped:
                isCalled = true
            default: XCTFail()
            }
        }

        viewModel.event(.backTapped)

        XCTAssertEqual(isCalled, true)
    }

    func testDelegateGetsCalledOnCloseTapped() {
        var isCalled = false

        viewModel.delegate = { event in
            switch event {
            case .closeTapped:
                isCalled = true
            default: XCTFail()
            }
        }

        viewModel.event(.closeTapped)

        XCTAssertEqual(isCalled, true)
    }

    func testDelegateGetsCalledOnCheckMessagesTapped() {
        var isCalled = false

        viewModel.delegate = { event in
            switch event {
            case .transcriptRequested:
                isCalled = true
            default: XCTFail()
            }
        }

        if case .welcome(let props) = viewModel.props() {
            props.checkMessageButtonTap.execute()
        }

        XCTAssertEqual(isCalled, true)
    }
}

// Is attachment available
extension SecureConversationsWelcomeViewModelTests {
    func testIsAttachmentAvailable() throws {
        var environment: WelcomeViewModel.Environment = .mock()
        let site: CoreSdkClient.Site = try .mock(
            allowedFileSenders: .init(operator: true, visitor: true)
        )

        environment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }

        viewModel = .init(environment: environment, availability: .mock)

        XCTAssertTrue(viewModel.isAttachmentsAvailable)
    }

    func testIsAttachmentNotAvailable() throws {
        var environment: WelcomeViewModel.Environment = .mock()
        let site: CoreSdkClient.Site = try .mock(
            allowedFileSenders: .init(operator: true, visitor: false)
        )

        environment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }

        viewModel = .init(environment: environment, availability: .mock)

        XCTAssertFalse(viewModel.isAttachmentsAvailable)
    }

    func testIsAttachmentAvailableFailed() {
        var environment: WelcomeViewModel.Environment = .mock()
        environment.fetchSiteConfigurations = { completion in
            completion(.failure(CoreSdkClient.GliaCoreError(reason: "")))
        }

        var isCalled = false
        var alertInputType: AlertInputType?

        let delegate: (WelcomeViewModel.DelegateEvent) -> Void = { event in
            switch event {
            case let .showAlert(type):
                isCalled = true
                alertInputType = type
            default: break
            }
        }

        viewModel = .init(environment: environment, availability: .mock, delegate: delegate)

        XCTAssertTrue(isCalled)
        let isValidInput: Bool
        if case .error = alertInputType {
            isValidInput = true
        } else {
            isValidInput = false
        }

        XCTAssertTrue(isValidInput)
    }

}

// Send message
extension SecureConversationsWelcomeViewModelTests {
    func testSuccessfulMessageSend() async {
        var isCalled = false
        viewModel.environment.secureConversations.sendMessagePayload = { _, _ in
            let mockedMessage = CoreSdkClient.Message(
                id: UUID.mock.uuidString,
                content: "Content",
                sender: .mock,
                metadata: nil
            )

            return mockedMessage
        }

        viewModel.delegate = { event in
            switch event {
            case .confirmationScreenRequested:
                isCalled = true
            default: break
            }
        }

        await viewModel.sendMessageCommand()

        XCTAssertEqual(viewModel.sendMessageRequestState, .waiting)
        XCTAssertTrue(isCalled)
    }

    func testFailedMessageSend() async {
        var isCalled = false
        var alertInputType: AlertInputType?
        viewModel.environment.secureConversations.sendMessagePayload = { _, _ in
            throw CoreSdkClient.GliaCoreError(reason: "")
        }

        viewModel.delegate = { event in
            switch event {
            case let .showAlert(type):
                isCalled = true
                alertInputType = type
            default: break
            }
        }

        await viewModel.sendMessageCommand()

        XCTAssertEqual(viewModel.sendMessageRequestState, .waiting)
        XCTAssertTrue(isCalled)
        let isValidInput: Bool
        if case .error = alertInputType {
            isValidInput = true
        } else {
            isValidInput = false
        }

        XCTAssertTrue(isValidInput)
    }
}

// Report change
extension SecureConversationsWelcomeViewModelTests {
    func testReportChangeIsCalledOnMessageTextChange() {
        executeReportChangeEvent { viewModel.messageText = "" }
    }

    func testReportChangeIsCalledOnAvailabilityStatusChange() {
        executeReportChangeEvent {
            viewModel.availabilityStatus = .unavailable(.unauthenticated)
        }
    }

    func testReportChangeIsCalledOnMessageInputStateChange() {
        executeReportChangeEvent { viewModel.messageInputState = .active }

    }

    func testReportChangeIsCalledOnSendMessageRequestStateChange() {
        executeReportChangeEvent { viewModel.sendMessageRequestState = .loading }
    }

    func testReportChangeIsCalledOnFileUploadListModelDelegateCall() {
        executeReportChangeEvent { viewModel.fileUploadListModel.delegate?(.renderProps(.mock)) }
    }

    private func executeReportChangeEvent(_ event: () -> ()) {
        var count = 0
        viewModel.delegate = { event in
            switch event {
            case .renderProps:
                count += 1
            default: XCTFail()
            }
        }

        event()
        XCTAssertTrue(count == 1)
    }
}

// Props
extension SecureConversationsWelcomeViewModelTests {
    func testWarningMessageWithinLimit() {
        viewModel.messageText = ""
        if case .welcome(let props) = viewModel.props() {
            props.checkMessageButtonTap.execute()
            XCTAssertTrue(props.warningMessage.text.isEmpty)
        } else {
            XCTFail()
        }
    }

    func testWarningMessageOutsideLimit() {
        viewModel.messageText = String(repeating: "a", count: 10001)
        if case .welcome(let props) = viewModel.props() {
            XCTAssertTrue(!props.warningMessage.text.isEmpty)
        } else {
            XCTFail()
        }
    }

    func testFilePickerButtonIsAvailable() throws {
        var environment: WelcomeViewModel.Environment = .mock()
        let site: CoreSdkClient.Site = try .mock(
            allowedFileSenders: .init(operator: true, visitor: true)
        )

        environment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }

        viewModel = .init(environment: environment, availability: .mock)
        viewModel.availabilityStatus = .available(.queues(queueIds: []))

        if case .welcome(let props) = viewModel.props() {
            XCTAssertNotNil(props.filePickerButton)
        } else {
            XCTFail()
        }
    }

    func testFilePickerButtonIsNotAvailable() {
        if case .welcome(let props) = viewModel.props() {
            XCTAssertNil(props.filePickerButton)
        } else {
            XCTFail()
        }
    }

    func testMessageTextViewPropsActive() {
        viewModel.messageInputState = .active

        if case .welcome(let props) = viewModel.props() {
            if case .active = props.messageTextViewProps {
                XCTAssertTrue(true)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }

    func testMessageTextViewPropsNormal() {
        viewModel.messageInputState = .normal

        if case .welcome(let props) = viewModel.props() {
            if case .normal = props.messageTextViewProps {
                XCTAssertTrue(true)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }

    func testMessageTextViewPropsDisabled() {
        viewModel.messageInputState = .disabled

        if case .welcome(let props) = viewModel.props() {
            if case .disabled = props.messageTextViewProps {
                XCTAssertTrue(true)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }

    func testSendMessageButtonStateUnavailable() {
        viewModel.availabilityStatus = .unavailable(.unauthenticated)

        if case .welcome(let props) = viewModel.props() {
            XCTAssertNil(props.sendMessageButton)
        } else {
            XCTFail()
        }
    }

    func testSendMessageButtonStateFileUploads() {
        viewModel.availabilityStatus = .available(.queues(queueIds: []))
        let uploadFile: FileUpload.Environment.UploadFile = .toSecureMessaging { file, progress, completion in
            completion(.failure(CoreSdkClient.GliaCoreError(reason: "")))
            return .mock
        }

        let environment = FileUpload.Environment(uploadFile: uploadFile, uuid: { UUID.mock })
        let fileUpload: FileUpload = .mock(environment: environment)
        fileUpload.startUpload()
        viewModel.fileUploadListModel.environment.uploader.uploads = [fileUpload]

        if case .welcome(let props) = viewModel.props() {
            XCTAssertEqual(props.sendMessageButton, .disabled)
        } else {
            XCTFail()
        }
    }

    func testSendMessageButtonStateInProgressFileUpload() {
        viewModel.availabilityStatus = .available(.queues(queueIds: []))
        let fileUpload: FileUpload = .mock()
        fileUpload.startUpload()
        viewModel.fileUploadListModel.environment.uploader.uploads = [fileUpload]

        if case .welcome(let props) = viewModel.props() {
            XCTAssertEqual(props.sendMessageButton, .disabled)
        } else {
            XCTFail()
        }
    }

    func testSendMessageButtonStateEmptyText() {
        viewModel.availabilityStatus = .available(.queues(queueIds: []))
        viewModel.messageText = ""

        if case .welcome(let props) = viewModel.props() {
            XCTAssertEqual(props.sendMessageButton, .disabled)
        } else {
            XCTFail()
        }
    }

    func testSendMessageButtonStateSuccessfulUpload() {
        viewModel.availabilityStatus = .available(.queues(queueIds: []))
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)
        viewModel.messageText = ""

        if case .welcome(let props) = viewModel.props() {
            XCTAssertEqual(props.sendMessageButton, .disabled)
        } else {
            XCTFail()
        }
    }

    func testSendMessageButtonStateNoQueues() {
        viewModel.availabilityStatus = .available(.queues(queueIds: []))
        viewModel.messageText = "text"
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)
        viewModel.environment.queueIds = []

        if case .welcome(let props) = viewModel.props() {
            XCTAssertEqual(props.sendMessageButton, .disabled)
        } else {
            XCTFail()
        }
    }

    func testSendMessageButtonStateLoadingMessageRequestState() {
        viewModel.availabilityStatus = .available(.queues(queueIds: []))
        viewModel.messageText = "text"
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)
        viewModel.environment.queueIds = [""]
        viewModel.sendMessageRequestState = .loading

        if case .welcome(let props) = viewModel.props() {
            XCTAssertEqual(props.sendMessageButton, .loading)
        } else {
            XCTFail()
        }
    }

    func testSendMessageButtonStateWaitingMessageRequestState() {
        viewModel.availabilityStatus = .available(.queues(queueIds: []))
        viewModel.messageText = "text"
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)
        viewModel.environment.queueIds = [""]
        viewModel.sendMessageRequestState = .waiting

        if case .welcome(let props) = viewModel.props() {
            XCTAssertEqual(props.sendMessageButton, .active(viewModel.sendMessageCommand))
        } else {
            XCTFail()
        }
    }
}

// Media picker
extension SecureConversationsWelcomeViewModelTests {
    func testMediaPickerCallsPickFile() {
        var isCalled = false

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.browse)
            case .pickFile:
                isCalled = true
            default: XCTFail()
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        XCTAssertTrue(isCalled)
    }

    func testMediaPickerCallsTakeMedia() {
        var isCalled = false

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.takePhoto)
            case .takeMedia:
                isCalled = true
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        XCTAssertTrue(isCalled)
    }

    func testMediaPickerCallsPickMedia() {
        var isCalled = false

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.photoLibrary)
            case .pickMedia:
                isCalled = true
            default: XCTFail()
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        XCTAssertTrue(isCalled)
    }

    func testMediaPickerCallsCancelledCallback() {
        var isCalled = false
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.photoLibrary)
            case .pickMedia(let callback):
                callback(.cancelled)
                isCalled = true
            case .showAlert:
                XCTFail()
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())
        XCTAssertTrue(isCalled)
    }

    func testMediaPickerCallsPickedMediaCallbackWithImage() {
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.takePhoto)
            case .takeMedia(let callback):
                callback(.pickedMedia(PickedMedia.image(URL.mock)))
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        XCTAssertTrue(!viewModel.fileUploadListModel.activeUploads.isEmpty)
    }

    func testMediaPickerCallsSourceNotAvailableCallback() {
        var isCalled = false
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.photoLibrary)
            case .pickMedia(let callback):
                callback(.sourceNotAvailable)
            case .showAlert:
                isCalled = true
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        XCTAssertTrue(isCalled)
    }

    func testMediaPickerCallsNoCameraPermissionCallback() {
        var isCalled = false
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.photoLibrary)
            case .pickMedia(let callback):
                callback(.noCameraPermission)
            case .showAlert:
                isCalled = true
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())
        XCTAssertTrue(isCalled)
    }

    func testMediaPickerCallsBrowseUploadCallback() {
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.browse)
            case .pickFile(let callback):
                callback(.pickedFile(URL.mock))
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        XCTAssertTrue(!viewModel.fileUploadListModel.activeUploads.isEmpty)
    }

    func testMediaPickerDoesNotCallBrowseUploadCallback() {
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)

        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.browse)
            case .pickFile(let callback):
                callback(.cancelled)
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        XCTAssertTrue(viewModel.fileUploadListModel.activeUploads.isEmpty)
    }
}

// Availability
extension SecureConversationsWelcomeViewModelTests {
    func testAvailabilityAvailable() {
        let uuid = UUID.mock.uuidString
        var availability = SecureConversations.Availability.mock
        availability.environment.getQueues = {
            let queue = Queue.mock(
                id: uuid,
                name: "",
                status: .open,
                isDefault: true,
                media: [.messaging]
            )
            return [queue]
        }
        availability.environment.isAuthenticated = { true }

        viewModel = .init(environment: .mock(queueIds: [uuid]), availability: availability)

        XCTAssertEqual(viewModel.availabilityStatus, .available(.queues(queueIds: [])))
    }

    func testAvailabilityUnavailableEmptyQueues() async {
        var alertInputType: AlertInputType?

        let uuid = UUID.mock.uuidString
        var availability = SecureConversations.Availability.mock
        availability.environment.getQueues = {
            let queue = Queue.mock(
                id: uuid,
                name: "",
                status: .open,
                isDefault: true,
                media: [.text]
            )
            return [queue]
        }

        availability.environment.isAuthenticated = { true }
        availability.environment.queuesMonitor = .mock(getQueues: availability.environment.getQueues)

        let delegate: (WelcomeViewModel.DelegateEvent) -> Void = { event in
            switch event {
            case let .showAlert(type):
                alertInputType = type
            default: break
            }
        }

        viewModel = .init(
            environment: .mock(queueIds: [uuid]),
            availability: availability,
            delegate: delegate
        )
        await viewModel.checkSecureConversationsAvailability()
        XCTAssertEqual(viewModel.availabilityStatus, .unavailable(.emptyQueue))
        let isValidInput: Bool
        if case .unavailableMessageCenter = alertInputType {
            isValidInput = true
        } else {
            isValidInput = false
        }

        XCTAssertTrue(isValidInput)
    }

    func testAvailabilityUnavailableUnauthenticated() async {
        var alertInputType: AlertInputType?

        let uuid = UUID.mock.uuidString
        var availability = SecureConversations.Availability.mock
        availability.environment.getQueues = {
            let queue = Queue.mock(
                id: uuid,
                name: "",
                status: .open,
                isDefault: true,
                media: [.messaging]
            )
            return [queue]
        }

        availability.environment.isAuthenticated = { false }
        availability.environment.queuesMonitor = .mock(getQueues: availability.environment.getQueues)

        let delegate: (WelcomeViewModel.DelegateEvent) -> Void = { event in
            switch event {
            case let .showAlert(type):
                alertInputType = type
            default: break
            }
        }

        viewModel = .init(
            environment: .mock(queueIds: [uuid]),
            availability: availability,
            delegate: delegate
        )
        await viewModel.checkSecureConversationsAvailability()

        XCTAssertEqual(viewModel.availabilityStatus, .unavailable(.unauthenticated))
        let isValidInput: Bool
        if case .unavailableMessageCenterForBeingUnauthenticated = alertInputType {
            isValidInput = true
        } else {
            isValidInput = false
        }
        XCTAssertTrue(isValidInput)
    }
}

// File upload
extension SecureConversationsWelcomeViewModelTests {
    func testFileUploadSelectsSecureEndpoint() {
        viewModel.environment.getCurrentEngagement = { nil }
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)
        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.photoLibrary)
            case .pickMedia(let callback):
                callback(.pickedMedia(PickedMedia.image(URL.mock)))
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        if case .toSecureMessaging = viewModel.fileUploadListModel.environment.uploader.environment.uploadFile {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }

    func testFileUploadSelectsChatEndpoint() {
        viewModel.environment.getCurrentEngagement = { .mock() }
        viewModel.fileUploadListModel.environment.uploader = FileUploader(maximumUploads: 100, environment: .mock)
        viewModel.delegate = { event in
            switch event {
            case let .mediaPickerRequested(_, callback):
                callback(.photoLibrary)
            case .pickMedia(let callback):
                callback(.pickedMedia(PickedMedia.image(URL.mock)))
            default: break
            }
        }

        viewModel.presentMediaPicker(from: UIView())

        if case .toEngagement = viewModel.fileUploadListModel.environment.uploader.environment.uploadFile {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
}
